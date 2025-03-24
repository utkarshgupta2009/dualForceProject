package com.dualforce.dualForceBackend.service;


import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.entity.documentEntities.DocumentChunk;
import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
import com.dualforce.dualForceBackend.repository.EmbeddingRepository;
import org.bson.types.ObjectId;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Component
@Service
public class DocumentEmbeddingService {

    private static final Logger logger = LoggerFactory.getLogger(DocumentEmbeddingService.class);
    private static final int TOKENS_OVERHEAD = 2;
    private static final int MAX_TOKENS_PER_REQUEST = 20000; // API limit

    private final EmbeddingRepository embeddingRepository;
    private final VertexAIService vertexAIService;
    private final UserService userService;

    @Value("${vertex.ai.max-tokens-per-text:2048}")
    private int maxTokensPerText;

    @Value("${vertex.ai.max-texts-per-request:250}")
    private int maxTextsPerRequest;

    @Value("${vertex.ai.max-concurrent-requests:10}")
    private int maxConcurrentRequests;

    @Value("${vertex.ai.rate-limit-delay-ms:100}")
    private int rateLimitDelayMs;

    @Autowired
    public DocumentEmbeddingService(EmbeddingRepository embeddingRepository, VertexAIService vertexAIService, UserService userService) {
        this.embeddingRepository = embeddingRepository;
        this.vertexAIService = vertexAIService;
        this.userService=userService;
    }

    public DocumentMetadata processDocument(MultipartFile file, boolean autoTruncate, String userId) throws IOException {
        String fileName = file.getOriginalFilename();
        logger.info("Processing document: {}", fileName);

        // Extract text from PDF
        String fullText = extractTextFromPDF(file.getInputStream());

        // Generate chunks with metadata
        List<DocumentChunk> enhancedChunks = extractEnhancedChunks(fullText, fileName);
        logger.info("Extracted {} chunks from document", enhancedChunks.size());

        // Process chunks and generate embeddings
        Map<String, Object> result = processPDFParallel(enhancedChunks, autoTruncate);
        ObjectId userIdObject = new ObjectId(userId);


        // Create document metadata
        DocumentMetadata documentMetadata = new DocumentMetadata();
        documentMetadata.setFilename(fileName);
        documentMetadata.setContentType(file.getContentType());
        documentMetadata.setSizeBytes(file.getSize());

        // Save metadata first to get the document ID
        documentMetadata = embeddingRepository.saveDocumentMetadata(documentMetadata);
        ObjectId documentId = documentMetadata.getId();

        // Store embeddings in repository with document ID
        saveEmbeddings(result, documentMetadata.getId());

        // Update the metadata with the chunk count
        int chunkCount = result.get("chunks") != null ? ((List<?>) result.get("chunks")).size() : 0;
        documentMetadata.setTotalChunks(chunkCount);

        return embeddingRepository.saveDocumentMetadata(documentMetadata);

    }

    private String extractTextFromPDF(InputStream inputStream) throws IOException {
        try (PDDocument document = PDDocument.load(inputStream)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }

    private List<DocumentChunk> extractEnhancedChunks(String fullText, String fileName) {
        // First split text into semantic chunks
        List<String> baseChunks = extractSemanticChunks(fullText);

        // Generate metadata for each chunk
        List<DocumentChunk> enhancedChunks = new ArrayList<>();
        int chunkIndex = 0;

        for (String chunk : baseChunks) {
            // Extract potential title from the chunk
            String chunkTitle = "Chunk " + (chunkIndex + 1);

            // Try to identify if this chunk contains a title or heading
            Pattern titlePattern = Pattern.compile("^(?:#\\s+|CHAPTER\\s+\\d+:?\\s+|(?:\\d+\\.)*\\d+\\s+)(.+)$", Pattern.MULTILINE);
            Matcher titleMatcher = titlePattern.matcher(chunk);

            if (titleMatcher.find()) {
                chunkTitle = titleMatcher.group(1).trim();
            }

            // Calculate a summary by selecting key sentences
            List<String> sentences = Arrays.asList(chunk.split("(?<=[.!?])\\s+"));
            String summary = "";

            if (sentences.size() > 3) {
                // Simple extractive summarization - first and last sentences often contain key information
                summary = sentences.get(0) + " " + sentences.get(sentences.size() - 1);
            } else if (!sentences.isEmpty()) {
                summary = sentences.get(0);
            }

            // Create enhanced chunk with metadata
            DocumentChunk enhancedChunk = new DocumentChunk();
            enhancedChunk.setContent(chunk);
            enhancedChunk.setIndex(chunkIndex++);
            enhancedChunk.setTitle(chunkTitle);
            enhancedChunk.setSummary(summary);
            enhancedChunk.setSource(fileName);
            enhancedChunk.setTokenCount(estimateTokenCount(chunk));

            enhancedChunks.add(enhancedChunk);
        }

        // Add overlapping chunks to improve retrieval of information that spans chunk boundaries
        addOverlappingChunks(enhancedChunks, baseChunks);

        return enhancedChunks;
    }

    private List<String> extractSemanticChunks(String text) {
        List<String> chunks = new ArrayList<>();
        int safeTokenLimit = (int) ((maxTokensPerText - TOKENS_OVERHEAD) * 0.9);

        // Enhanced section detection for more meaningful breaks
        // Detect a wider range of section headers and formatting patterns
        Pattern sectionRegex = Pattern.compile(
                "(?:\\n\\s*#{1,3}\\s+|\\n\\s*[A-Z][A-Z\\s]+(?:\\n|:)|\\n\\s*\\d+\\.\\s+[A-Z]|\\n\\s*CHAPTER\\s+\\d+|" +
                        "\\n\\s*Section\\s+\\d+\\.|\\n\\s*\\d+\\.\\d+\\s+[A-Z]|\\n\\s*[A-Z][a-zA-Z\\s]+:|\\n\\s*[IVX]+\\.\\s+[A-Z])",
                Pattern.CASE_INSENSITIVE
        );

        // Split by section markers
        String[] sections = sectionRegex.split(text);
        Matcher markerMatcher = sectionRegex.matcher(text);
        List<String> markers = new ArrayList<>();

        while (markerMatcher.find()) {
            markers.add(markerMatcher.group(0));
        }

        StringBuilder currentChunk = new StringBuilder();
        int currentTokenCount = 0;
        int sectionIndex = 0;

        // Process sections with their header markers
        for (String section : sections) {
            // Add the section marker/header back to its section
            String currentSection = section;
            if (sectionIndex < markers.size()) {
                currentSection = markers.get(sectionIndex) + currentSection;
            }
            sectionIndex++;

            // Clean the section
            currentSection = currentSection.trim();
            if (currentSection.isEmpty()) continue;

            // Split section into semantic paragraphs
            List<String> paragraphs = splitIntoSemanticParagraphs(currentSection);

            for (String paragraph : paragraphs) {
                paragraph = paragraph.trim();
                if (paragraph.isEmpty()) continue;

                int paragraphTokens = estimateTokenCount(paragraph);

                // If paragraph fits within token limit
                if (paragraphTokens <= safeTokenLimit) {
                    if (currentTokenCount + paragraphTokens > safeTokenLimit) {
                        // Current chunk is full, add it to list and start a new one
                        if (currentChunk.length() > 0) {
                            chunks.add(currentChunk.toString().trim());
                            currentChunk = new StringBuilder();
                            currentTokenCount = 0;
                        }
                    }

                    // Add paragraph to current chunk
                    currentChunk.append(paragraph).append("\n\n");
                    currentTokenCount += paragraphTokens;
                } else {
                    // Paragraph is too large, need to split further
                    if (currentChunk.length() > 0) {
                        chunks.add(currentChunk.toString().trim());
                        currentChunk = new StringBuilder();
                        currentTokenCount = 0;
                    }

                    // Split paragraph into smaller context-preserving chunks
                    chunks.addAll(splitLargeParagraph(paragraph, safeTokenLimit));
                }
            }
        }

        // Add any remaining content
        if (currentChunk.length() > 0) {
            chunks.add(currentChunk.toString().trim());
        }

        return chunks;
    }

    private List<String> splitIntoSemanticParagraphs(String text) {
        // First split by conventional paragraph markers (multiple newlines)
        String[] initialParagraphs = text.split("\n{2,}");
        List<String> refinedParagraphs = new ArrayList<>();

        for (String paragraph : initialParagraphs) {
            paragraph = paragraph.trim();
            if (paragraph.isEmpty()) continue;

            // Skip if it's already a reasonably sized paragraph
            if (paragraph.length() < 1000) {
                refinedParagraphs.add(paragraph);
                continue;
            }

            // For longer paragraphs, try to find semantic breaks based on topic shifts
            Pattern topicTransitions = Pattern.compile(
                    "(?:\\. (?:However|Moreover|Furthermore|In addition|In contrast|On the other hand|Similarly|" +
                            "Consequently|Therefore|Thus|As a result|Specifically|For example|For instance|In particular|" +
                            "To illustrate|In summary|In conclusion|Finally|Notably|Interestingly|Importantly))",
                    Pattern.CASE_INSENSITIVE
            );

            String[] parts = topicTransitions.split(paragraph);

            if (parts.length > 1) {
                // Add first part
                refinedParagraphs.add(parts[0].trim() + ".");

                // Add remaining parts with their transition phrases
                Matcher matcher = topicTransitions.matcher(paragraph);
                int matchIndex = 0;
                List<String> matches = new ArrayList<>();

                while (matcher.find()) {
                    matches.add(matcher.group(0));
                }

                for (int i = 1; i < parts.length; i++) {
                    if (matchIndex < matches.size()) {
                        String transitionWord = matches.get(matchIndex);
                        // Remove the period at the beginning of the transition word since it was kept in the previous part
                        transitionWord = transitionWord.substring(2);
                        refinedParagraphs.add(transitionWord + " " + parts[i].trim());
                        matchIndex++;
                    } else {
                        refinedParagraphs.add(parts[i].trim());
                    }
                }
            } else {
                // If no semantic breaks found, fall back to sentence-based chunking for very long paragraphs
                if (paragraph.length() > 2500) {
                    String[] sentences = paragraph.split("(?<=[.!?])\\s+");
                    StringBuilder currentPart = new StringBuilder();

                    for (String sentence : sentences) {
                        if (currentPart.length() + sentence.length() > 1000) {
                            refinedParagraphs.add(currentPart.toString().trim());
                            currentPart = new StringBuilder();
                        }
                        currentPart.append(sentence).append(" ");
                    }

                    if (currentPart.length() > 0) {
                        refinedParagraphs.add(currentPart.toString().trim());
                    }
                } else {
                    refinedParagraphs.add(paragraph);
                }
            }
        }

        return refinedParagraphs;
    }

    private List<String> splitLargeParagraph(String paragraph, int safeTokenLimit) {
        List<String> result = new ArrayList<>();

        // First try to split by sentences
        String[] sentences = paragraph.split("(?<=[.!?])\\s+");
        StringBuilder currentChunk = new StringBuilder();
        int currentTokenCount = 0;

        for (String sentence : sentences) {
            sentence = sentence.trim();
            if (sentence.isEmpty()) continue;

            int sentenceTokens = estimateTokenCount(sentence);

            // If this single sentence is too large (unusual but possible)
            if (sentenceTokens > safeTokenLimit) {
                // Add any accumulated content first
                if (currentChunk.length() > 0) {
                    result.add(currentChunk.toString().trim());
                    currentChunk = new StringBuilder();
                    currentTokenCount = 0;
                }

                // Split sentence by clauses (commas, semicolons, etc.)
                String[] clauses = sentence.split("(?<=[,;:])\\s+");
                StringBuilder clauseChunk = new StringBuilder();
                int clauseTokenCount = 0;

                for (String clause : clauses) {
                    clause = clause.trim();
                    if (clause.isEmpty()) continue;

                    int clauseTokens = estimateTokenCount(clause);

                    if (clauseTokenCount + clauseTokens > safeTokenLimit) {
                        if (clauseChunk.length() > 0) {
                            result.add(clauseChunk.toString().trim());
                            clauseChunk = new StringBuilder();
                            clauseTokenCount = 0;
                        }

                        // If a single clause is still too big, we need to split by words
                        if (clauseTokens > safeTokenLimit) {
                            String[] words = clause.split(" ");
                            StringBuilder wordChunk = new StringBuilder();
                            int wordTokenCount = 0;

                            for (String word : words) {
                                int wordTokens = estimateTokenCount(word);

                                if (wordTokenCount + wordTokens > safeTokenLimit) {
                                    result.add(wordChunk.toString().trim());
                                    wordChunk = new StringBuilder();
                                    wordTokenCount = 0;
                                }

                                wordChunk.append(word).append(" ");
                                wordTokenCount += wordTokens;
                            }

                            if (wordChunk.length() > 0) {
                                result.add(wordChunk.toString().trim());
                            }
                        } else {
                            clauseChunk.append(clause).append(" ");
                            clauseTokenCount = clauseTokens;
                        }
                    } else {
                        clauseChunk.append(clause).append(" ");
                        clauseTokenCount += clauseTokens;
                    }
                }

                if (clauseChunk.length() > 0) {
                    result.add(clauseChunk.toString().trim());
                }
            }
            // Normal case: Check if adding this sentence would exceed the limit
            else if (currentTokenCount + sentenceTokens > safeTokenLimit) {
                result.add(currentChunk.toString().trim());
                currentChunk = new StringBuilder();
                currentChunk.append(sentence).append(" ");
                currentTokenCount = sentenceTokens;
            } else {
                currentChunk.append(sentence).append(" ");
                currentTokenCount += sentenceTokens;
            }
        }

        if (currentChunk.length() > 0) {
            result.add(currentChunk.toString().trim());
        }

        return result;
    }

    private void addOverlappingChunks(List<DocumentChunk> enhancedChunks, List<String> baseChunks) {
        int safeTokenLimit = (int) ((maxTokensPerText - TOKENS_OVERHEAD) * 0.9);
        int lastIndex = enhancedChunks.size() > 0 ? enhancedChunks.get(enhancedChunks.size() - 1).getIndex() + 1 : 0;

        // Create overlapping chunks between adjacent chunks
        for (int i = 0; i < baseChunks.size() - 1; i++) {
            String currentChunk = baseChunks.get(i);
            String nextChunk = baseChunks.get(i + 1);

            // Extract end of current chunk (last ~30% of content)
            String[] currentChunkWords = currentChunk.split("\\s+");
            int endIndex = (int) (currentChunkWords.length * 0.7);

            if (endIndex >= currentChunkWords.length) continue;

            StringBuilder currentChunkEnd = new StringBuilder();
            for (int j = endIndex; j < currentChunkWords.length; j++) {
                currentChunkEnd.append(currentChunkWords[j]).append(" ");
            }

            // Extract beginning of next chunk (first ~30% of content)
            String[] nextChunkWords = nextChunk.split("\\s+");
            int beginIndex = (int) (nextChunkWords.length * 0.3);

            if (beginIndex >= nextChunkWords.length) continue;

            StringBuilder nextChunkBegin = new StringBuilder();
            for (int j = 0; j < beginIndex; j++) {
                nextChunkBegin.append(nextChunkWords[j]).append(" ");
            }

            // Combine them to create an overlapping chunk
            String overlapChunk = currentChunkEnd.toString().trim() + " " + nextChunkBegin.toString().trim();

            // Check if the overlap chunk is within token limits
            if (estimateTokenCount(overlapChunk) <= safeTokenLimit) {
                DocumentChunk overlapDocChunk = new DocumentChunk();
                overlapDocChunk.setContent(overlapChunk);
                overlapDocChunk.setIndex(lastIndex++);
                overlapDocChunk.setTitle("Overlap " + (i + 1) + "-" + (i + 2));
                overlapDocChunk.setSummary("Overlap between chunks " + (i + 1) + " and " + (i + 2));
                overlapDocChunk.setSource(enhancedChunks.get(0).getSource());
                overlapDocChunk.setTokenCount(estimateTokenCount(overlapChunk));
                overlapDocChunk.setOverlap(true);

                enhancedChunks.add(overlapDocChunk);
            }
        }
    }

    private int estimateTokenCount(String text) {
        if (text == null || text.isEmpty()) return 0;

        // Character-based estimation with adjustment factor
        // Google Vertex AI typically uses around 4 characters per token on average for English text
        int characters = text.length();
        int estimate = (int) Math.ceil(characters / 4.0);

        // Add overhead for special tokens
        estimate += TOKENS_OVERHEAD;

        // Add safety factor (30%)
        return (int) Math.ceil(estimate * 1.3);
    }

    public List<Double> getQueryEmbedding(String query) {
        if (query.isEmpty()) {
            throw new IllegalArgumentException("Query cannot be empty");
        }

        return vertexAIService.getQueryEmbedding(query);
    }

    private Map<String, Object> processPDFParallel(List<DocumentChunk> enhancedChunks, boolean autoTruncate) {
        // Separate content from metadata
        List<String> contentChunks = enhancedChunks.stream()
                .map(DocumentChunk::getContent)
                .collect(Collectors.toList());

        // Calculate token counts
        int totalEstimatedTokens = enhancedChunks.stream()
                .mapToInt(DocumentChunk::getTokenCount)
                .sum();

        logger.info("Total estimated tokens: {}", totalEstimatedTokens);

        // Use an optimized token limit that balances safety and performance
        // 15000 is 75% of the actual 20000 limit, giving us a good safety margin
        final int OPTIMIZED_TOKEN_LIMIT = 15000;

        // Create batches with better performance than ultra-conservative approach
        List<List<String>> batches = new ArrayList<>();
        List<String> currentBatch = new ArrayList<>();
        int currentBatchTokens = 0;

        for (int i = 0; i < contentChunks.size(); i++) {
            final String chunk = contentChunks.get(i);
            final int tokenCount = enhancedChunks.get(i).getTokenCount();

            // If this single chunk is too large, we need to handle it separately
            if (tokenCount > maxTokensPerText) {
                logger.warn("Warning: Chunk {} has estimated {} tokens, exceeding the per-text limit",
                        i+1, tokenCount);

                if (autoTruncate) {
                    logger.info("Auto-truncate is enabled. The API will truncate this chunk.");
                    // Process this chunk alone in its own batch
                    batches.add(Collections.singletonList(chunk));
                } else {
                    logger.info("Skipping chunk {} as it exceeds the token limit and auto-truncate is disabled", i+1);
                }
                continue;
            }

            // If adding this chunk would exceed our token limit or max texts per request, start a new batch
            if (currentBatchTokens + tokenCount > OPTIMIZED_TOKEN_LIMIT ||
                    currentBatch.size() >= maxTextsPerRequest) {
                if (!currentBatch.isEmpty()) {
                    batches.add(new ArrayList<>(currentBatch));
                    currentBatch.clear();
                    currentBatchTokens = 0;
                }
            }

            // Add the chunk to the current batch
            currentBatch.add(chunk);
            currentBatchTokens += tokenCount;
        }

        // Add the final batch if it's not empty
        if (!currentBatch.isEmpty()) {
            batches.add(new ArrayList<>(currentBatch));
        }

        logger.info("Created {} batches for processing", batches.size());

        // Process all batches with controlled concurrency
        List<List<Double>> allEmbeddings = new ArrayList<>();
        List<String> allProcessedChunks = new ArrayList<>();
        List<DocumentChunk> allProcessedMetadata = new ArrayList<>();
        Map<String, Integer> processedChunkIndices = new HashMap<>();

        ExecutorService executor = Executors.newFixedThreadPool(maxConcurrentRequests);
        List<CompletableFuture<Void>> futures = new ArrayList<>();

        // Add rate limiting delay (using sleep in completablefuture isn't ideal but works for demonstration)
        Duration rateLimitDelay = Duration.ofMillis(rateLimitDelayMs);

        for (int i = 0; i < batches.size(); i++) {
            final int batchIndex = i;

            CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
                try {
                    logger.info("Processing batch {}/{} with {} chunks",
                            batchIndex+1, batches.size(), batches.get(batchIndex).size());

                    // Process the entire batch
                    List<List<Double>> batchEmbeddings = vertexAIService.getBatchEmbeddings(batches.get(batchIndex));

                    // Track which chunks were processed and their original indices
                    synchronized (allEmbeddings) {
                        for (int j = 0; j < batches.get(batchIndex).size(); j++) {
                            final String chunk = batches.get(batchIndex).get(j);
                            final int originalIndex = contentChunks.indexOf(chunk);

                            if (originalIndex >= 0 && j < batchEmbeddings.size()) {
                                allEmbeddings.add(batchEmbeddings.get(j));
                                allProcessedChunks.add(chunk);
                                allProcessedMetadata.add(enhancedChunks.get(originalIndex));
                                processedChunkIndices.put(chunk, originalIndex);
                            }
                        }
                    }

                    logger.info("Completed batch {}/{}. Total embeddings: {}",
                            batchIndex+1, batches.size(), allEmbeddings.size());
                } catch (Exception e) {
                    logger.error("Error processing batch {}: {}", batchIndex+1, e.getMessage());

                    // If the batch has more than one chunk and fails, try processing in smaller batches
                    if (batches.get(batchIndex).size() > 1) {
                        logger.info("Splitting batch {} into smaller batches", batchIndex+1);

                        // Split the batch in half and try again
                        int half = batches.get(batchIndex).size() / 2;
                        List<String> firstHalf = batches.get(batchIndex).subList(0, half);
                        List<String> secondHalf = batches.get(batchIndex).subList(half, batches.get(batchIndex).size());

                        try {
                            logger.info("Processing first half of batch {} ({} chunks)", batchIndex+1, firstHalf.size());
                            List<List<Double>> firstHalfEmbeddings = vertexAIService.getBatchEmbeddings(firstHalf);

                            synchronized (allEmbeddings) {
                                for (int j = 0; j < firstHalf.size(); j++) {
                                    final String chunk = firstHalf.get(j);
                                    final int originalIndex = contentChunks.indexOf(chunk);

                                    if (originalIndex >= 0 && j < firstHalfEmbeddings.size()) {
                                        allEmbeddings.add(firstHalfEmbeddings.get(j));
                                        allProcessedChunks.add(chunk);
                                        allProcessedMetadata.add(enhancedChunks.get(originalIndex));
                                        processedChunkIndices.put(chunk, originalIndex);
                                    }
                                }
                            }
                        } catch (Exception e1) {
                            logger.error("Error processing first half of batch {}: {}", batchIndex+1, e1.getMessage());
                            // Process individually if half batch fails
                            processChunksIndividually(firstHalf, enhancedChunks, contentChunks,
                                    allEmbeddings, allProcessedChunks, allProcessedMetadata);
                        }

                        try {
                            logger.info("Processing second half of batch {} ({} chunks)", batchIndex+1, secondHalf.size());
                            List<List<Double>> secondHalfEmbeddings = vertexAIService.getBatchEmbeddings(secondHalf);

                            synchronized (allEmbeddings) {
                                for (int j = 0; j < secondHalf.size(); j++) {
                                    final String chunk = secondHalf.get(j);
                                    final int originalIndex = contentChunks.indexOf(chunk);

                                    if (originalIndex >= 0 && j < secondHalfEmbeddings.size()) {
                                        allEmbeddings.add(secondHalfEmbeddings.get(j));
                                        allProcessedChunks.add(chunk);
                                        allProcessedMetadata.add(enhancedChunks.get(originalIndex));
                                        processedChunkIndices.put(chunk, originalIndex);
                                    }
                                }
                            }
                        } catch (Exception e2) {
                            logger.error("Error processing second half of batch {}: {}", batchIndex+1, e2.getMessage());
                            // Process individually if half batch fails
                            processChunksIndividually(secondHalf, enhancedChunks, contentChunks,
                                    allEmbeddings, allProcessedChunks, allProcessedMetadata);
                        }
                    } else {
                        // Single chunk batch failed, skip it
                        logger.info("Skipping single chunk in batch {} due to API error", batchIndex+1);
                    }
                }
            }, executor);

            futures.add(future);

            // Add delay between batch submissions for rate limiting
            if (i < batches.size() - 1) {
                try {
                    Thread.sleep(rateLimitDelay.toMillis());
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }

        // Wait for all futures to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();
        executor.shutdown();

        logger.info("Embedding generation completed. Total embeddings: {}", allEmbeddings.size());
        logger.info("Successfully processed {}/{} chunks", allProcessedChunks.size(), contentChunks.size());

        // Return the chunks that were successfully processed with their embeddings and metadata
        Map<String, Object> result = new HashMap<>();
        result.put("chunks", allProcessedChunks);
        result.put("embeddings", allEmbeddings);
        result.put("metadata", allProcessedMetadata);

        return result;
    }

    private void processChunksIndividually(
            List<String> chunks,
            List<DocumentChunk> enhancedChunks,
            List<String> originalContentChunks,
            List<List<Double>> allEmbeddings,
            List<String> allProcessedChunks,
            List<DocumentChunk> allProcessedMetadata) {

        logger.info("Processing {} chunks individually", chunks.size());

        for (int i = 0; i < chunks.size(); i++) {
            try {
                List<List<Double>> singleEmbedding = vertexAIService.getBatchEmbeddings(
                        Collections.singletonList(chunks.get(i)));

                // Find the original index of this chunk
                final int originalIndex = originalContentChunks.indexOf(chunks.get(i));

                synchronized (allEmbeddings) {
                    if (originalIndex >= 0 && !singleEmbedding.isEmpty()) {
                        allEmbeddings.addAll(singleEmbedding);
                        allProcessedChunks.add(chunks.get(i));
                        allProcessedMetadata.add(enhancedChunks.get(originalIndex));
                    }
                }

                logger.info("Processed individual chunk {}/{}", i+1, chunks.size());
            } catch (Exception e) {
                logger.error("Error processing individual chunk {}/{}: {}", i+1, chunks.size(), e.getMessage());
            }

            // Small delay between individual requests to avoid rate limiting
            if (i < chunks.size() - 1) {
                try {
                    Thread.sleep(50);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    private void saveEmbeddings(Map<String, Object> result, ObjectId documentId) {
        if (result == null || !result.containsKey("chunks") || !result.containsKey("embeddings") || !result.containsKey("metadata")) {
            logger.warn("Invalid result map. Cannot save embeddings.");
            return;
        }

        @SuppressWarnings("unchecked")
        List<String> chunks = (List<String>) result.get("chunks");

        @SuppressWarnings("unchecked")
        List<List<Double>> embeddings = (List<List<Double>>) result.get("embeddings");

        @SuppressWarnings("unchecked")
        List<DocumentChunk> metadata = (List<DocumentChunk>) result.get("metadata");

        if (chunks.size() != embeddings.size() || chunks.size() != metadata.size()) {
            logger.warn("Mismatch in result map lists sizes. Cannot save embeddings.");
            return;
        }

        // Save embeddings through repository
        for (int i = 0; i < chunks.size(); i++) {
            embeddingRepository.saveEmbedding(
                    metadata.get(i).getSource(),
                    chunks.get(i),
                    embeddings.get(i),
                    metadata.get(i),
                    documentId.toHexString()
            );
        }
    }
}