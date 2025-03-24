package com.dualforce.dualForceBackend.service;

import com.dualforce.dualForceBackend.entity.ConversationMessage;
import com.dualforce.dualForceBackend.entity.ExpertSystem;
import com.dualforce.dualForceBackend.entity.SearchResult;
import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
import com.dualforce.dualForceBackend.repository.ExpertSystemRepository;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
public class ExpertSystemService {

    @Autowired
    private  DocumentEmbeddingService documentEmbeddingService;
    @Autowired
    private  UserService userService;
    @Autowired
    private VertexAIService vertexAIService;
    @Autowired
    private ExpertSystemRepository expertSystemRepository;
    @Autowired
    private MongoTemplate mongoTemplate;

    private static final Logger logger = LoggerFactory.getLogger(DocumentEmbeddingService.class);



    public ExpertSystem CreateExpertSystem(MultipartFile file, String userId, String nameofExpertSystem, String descriptionOfExpertSystem, boolean autoTruncate) throws IOException {
        User user = userService.getUserById(userId);
        // Process document
        if(user==null){
            throw new IOException("User does not exists");
        }
        DocumentMetadata documentMetadata = documentEmbeddingService.processDocument(file, autoTruncate, userId);
        //update expert system
        ExpertSystem expertSystem = new ExpertSystem();
        expertSystem.setName(nameofExpertSystem);
        expertSystem.setDescription(descriptionOfExpertSystem);
        expertSystem.setDocumentMetadata(documentMetadata);
        expertSystem.setUser(user);
        final LocalDateTime currentDateTime = LocalDateTime.now();
        expertSystem.setCreatedAt(currentDateTime);
        expertSystem.setUpdatedAt(currentDateTime);
        ExpertSystem expertSystemSaved = expertSystemRepository.save(expertSystem);

        user.getExpertSystems().add(expertSystemSaved);
        userService.updateUser(user);

        return expertSystemSaved;

    }

    public String sendMessage(String expertSystemId, String query, List<ConversationMessage> previousMessages, int limit) {
        try {
            ExpertSystem expertSystem = expertSystemRepository.findExpertSystemById(expertSystemId);
            // 1. Perform vector search to find relevant document sections
            List<SearchResult> searchResults = performVectorSearch(expertSystem.getDocumentMetadata().getId(), query, limit);

            if (searchResults.isEmpty()) {
                logger.warn("No relevant document sections found for query: {}", query);
                return "I couldn't find any relevant information in the document to answer your question.";
            }

            // 2. Send to Gemini AI with document sections and conversation history
            return vertexAIService.sendMessage(query, searchResults, previousMessages,expertSystem);

        } catch (Exception e) {
            logger.error("Error during document search and response generation: {}", e.getMessage());
            throw new RuntimeException("Failed to process your request: " + e.getMessage(), e);
        }
    }

    /**
     * Performs vector search to find relevant document sections
     */
    private List<SearchResult> performVectorSearch(ObjectId documentId, String query, int limit) {
        try {
            // Generate embedding for the query
            List<Double> queryEmbedding = vertexAIService.getQueryEmbedding(query);

            // Use the List<Double> directly instead of converting to primitive array
            // Create the MongoDB vector search aggregation pipeline
            List<Document> pipeline = new ArrayList<>();

            // First stage: Vector search without filter
            pipeline.add(new Document("$vectorSearch",
                    new Document("queryVector", queryEmbedding)
                            .append("path", "vector")
                            .append("numCandidates", limit * 10)
                            .append("limit", limit)
                            .append("index", "vector_search")
            ));





            // Third stage: Project only the needed fields and include the score
            pipeline.add(new Document("$project",
                    new Document("_id", 1)

                            .append("content", 1)
                            .append("title", 1)
                            .append("summary", 1)
                            .append("source", 1)  // Changed from 0 to 1 to include source
                            .append("score", new Document("$meta", "vectorSearchScore"))
            ));

            // Execute the aggregation pipeline
            List<Document> results = mongoTemplate.getCollection("embeddings")
                    .aggregate(pipeline)
                    .into(new ArrayList<>());

            // Convert results to SearchResult objects
            return results.stream()
                    .map(doc -> {
                        SearchResult result = new SearchResult();
                        // Set other fields
                        result.setChunkId(doc.getObjectId("_id"));
                        result.setContent(doc.getString("content"));
                        result.setTitle(doc.getString("title"));
                        result.setSummary(doc.getString("summary"));
                        result.setSource(doc.getString("source"));
                        result.setScore(doc.getDouble("score"));

                        return result;
                    })
                    .collect(Collectors.toList());

        } catch (Exception e) {
            logger.error("Error during vector search: {}", e.getMessage());
            throw new RuntimeException("Failed to perform vector search: " + e.getMessage(), e);
        }
    }
}