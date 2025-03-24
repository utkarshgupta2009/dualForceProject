package com.dualforce.dualForceBackend.service;

import com.dualforce.dualForceBackend.entity.ConversationMessage;
import com.dualforce.dualForceBackend.entity.ExpertSystem;
import com.dualforce.dualForceBackend.entity.SearchResult;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.auth.oauth2.ServiceAccountCredentials;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.ClientRequest;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import javax.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@Service
public class VertexAIService {

    private static final Logger logger = LoggerFactory.getLogger(VertexAIService.class);
    private WebClient webClient;
    private final WebClient.Builder webClientBuilder;
    private final ObjectMapper objectMapper;
    private GoogleCredentials credentials;

    @Value("${vertex.ai.project-id}")
    private String projectId;

    @Value("${vertex.ai.location:us-central1}")
    private String location;

    @Value("${vertex.ai.model-name:text-embedding-005}")
    private String modelName;

    @Value("${vertex.ai.auto-truncate:true}")
    private boolean autoTruncate;

//    @Value("${gcp.credentials.path:#{null}}")
//    private String credentialsPath;

//    @Value("${gcp.use.adc:true}")
//    private boolean useAdc;

    public VertexAIService(WebClient.Builder webClientBuilder) {
        this.webClientBuilder = webClientBuilder;
        this.objectMapper = new ObjectMapper();
    }

    @PostConstruct
    public void initialize() {
        try {
            // Load credentials
            this.credentials = loadCredentials();

            // Log the values to verify they're properly injected
            logger.info("Initializing VertexAIService with location: {}", location);
            logger.info("Model name: {}", modelName);
            logger.info("Project ID: {}", projectId);

                logger.info("Using Application Default Credentials");


            this.webClient = webClientBuilder
                    .baseUrl("https://" + location + "-aiplatform.googleapis.com/v1")
                    .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                    .filter(authorizationFilter())
                    .build();
        } catch (Exception e) {
            logger.error("Failed to initialize VertexAIService: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to initialize VertexAIService", e);
        }
    }

    /**
     * Load Google Cloud credentials using Application Default Credentials (ADC) when deployed
     * or from a service account JSON file for local development
     */
    private GoogleCredentials loadCredentials() throws IOException {
            logger.info("Loading Application Default Credentials");
            return GoogleCredentials.getApplicationDefault()
                    .createScoped("https://www.googleapis.com/auth/cloud-platform");

    }

    /**
     * Create an authorization filter that adds the OAuth token to each request
     */
    private ExchangeFilterFunction authorizationFilter() {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            try {
                // Ensure the token is valid (refreshes if needed)
                credentials.refreshIfExpired();
                String token = credentials.getAccessToken().getTokenValue();

                // Add Authorization header with token to the request
                ClientRequest authorizedRequest = ClientRequest.from(clientRequest)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .build();

                return Mono.just(authorizedRequest);
            } catch (IOException e) {
                logger.error("Failed to refresh token: {}", e.getMessage());
                return Mono.error(new RuntimeException("Failed to refresh token", e));
            }
        });
    }

    // Rest of your methods remain unchanged...
    public List<Double> getQueryEmbedding(String query) {
        try {
            if (query.isEmpty()) {
                throw new IllegalArgumentException("Query cannot be empty");
            }

            // Construct the API endpoint for text embeddings
            String endpoint = "/projects/" + projectId + "/locations/" + location +
                    "/publishers/google/models/" + modelName + ":predict";

            // Prepare the request body
            ObjectNode requestBody = objectMapper.createObjectNode();
            ArrayNode instances = requestBody.putArray("instances");

            ObjectNode instance = objectMapper.createObjectNode();
            instance.put("task_type", "QUESTION_ANSWERING");
            instance.put("content", query);
            instances.add(instance);

            ObjectNode parameters = requestBody.putObject("parameters");
            parameters.put("outputDimensionality", 768);
            parameters.put("autoTruncate", autoTruncate);

            // Make the API call
            String responseBody = webClient.post()
                    .uri(endpoint)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            if (responseBody != null) {
                JsonNode responseJson = objectMapper.readTree(responseBody);

                // Get the embedding values from the response
                JsonNode embeddingsNode = responseJson
                        .path("predictions")
                        .path(0)
                        .path("embeddings")
                        .path("values");

                // Convert to List<Double>
                return StreamSupport.stream(embeddingsNode.spliterator(), false)
                        .map(JsonNode::asDouble)
                        .collect(Collectors.toList());
            } else {
                throw new RuntimeException("Empty response from API");
            }
        } catch (Exception e) {
            logger.error("Failed to get query embedding: {}", e.getMessage());
            throw new RuntimeException("Failed to get query embedding: " + e.getMessage(), e);
        }
    }

    public List<List<Double>> getBatchEmbeddings(List<String> textChunks) {
        if (textChunks.isEmpty()) {
            return new ArrayList<>();
        }

        // Filter out empty chunks
        List<String> validatedChunks = textChunks.stream()
                .filter(chunk -> !chunk.isEmpty())
                .toList();

        if (validatedChunks.isEmpty()) {
            return new ArrayList<>();
        }

        try {
            // Construct the API endpoint for batch embeddings
            String endpoint = "/projects/" + projectId + "/locations/" + location +
                    "/publishers/google/models/" + modelName + ":predict";

            // Create appropriate request format for batch processing
            ObjectNode requestBody = objectMapper.createObjectNode();
            ArrayNode instances = requestBody.putArray("instances");

            for (String text : validatedChunks) {
                ObjectNode instance = objectMapper.createObjectNode();
                instance.put("task_type", "QUESTION_ANSWERING");
                instance.put("content", text);
                instances.add(instance);
            }

            ObjectNode parameters = requestBody.putObject("parameters");
            parameters.put("outputDimensionality", 768);
            parameters.put("autoTruncate", autoTruncate);

            // Make the API call
            String responseBody = webClient.post()
                    .uri(endpoint)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            if (responseBody != null) {
                JsonNode responseJson = objectMapper.readTree(responseBody);

                // Extract embeddings from response
                JsonNode predictions = responseJson.path("predictions");
                List<List<Double>> result = new ArrayList<>();

                for (JsonNode prediction : predictions) {
                    JsonNode embeddingsNode = prediction.path("embeddings").path("values");

                    List<Double> embedding = StreamSupport.stream(embeddingsNode.spliterator(), false)
                            .map(JsonNode::asDouble)
                            .collect(Collectors.toList());

                    result.add(embedding);
                }

                return result;
            } else {
                throw new RuntimeException("Empty response from API");
            }
        } catch (Exception e) {
            logger.error("Failed to get batch embeddings: {}", e.getMessage());
            throw new RuntimeException("Failed to get batch embeddings: " + e.getMessage(), e);
        }
    }

    /**
     * Sends a message to Gemini AI with RAG context and conversation history
     *
     * @param query The user's query
     * @param documentSections List of relevant document sections from vector search
     * @param previousMessages Previous conversation messages for context (optional)
     * @return The AI response
     */
    public String sendMessage(String query, List<SearchResult> documentSections, List<ConversationMessage> previousMessages, ExpertSystem expertSystem) {
        try {
            // Construct the API endpoint for Gemini
            String endpoint = "/projects/" + projectId + "/locations/" + location +
                    "/publishers/google/models/gemini-1.5-pro:generateContent";

            // Create the request body
            ObjectNode requestBody = objectMapper.createObjectNode();

            // Add system prompt
            String systemPrompt = """
                    You are a %s expert system powered by Google's Vertex AI, your description is %s. You are designed to provide accurate and helpful responses based on the provided document sections. Always use the relevant information from the document sections to formulate your responses. Instructions:
                    1. Always match the user query with document sections, if the query is generic then ignore document text and respond by saying things like i am here to help you or anything suited but do not give answers to query that does not match at all with context, like do not respond to query like lets play a game or anything unless context is specified.
                    2. Base your response primarily on the provided document sections
                    3. Use the conversation history for context
                    4. If multiple sections are relevant, synthesize information from all of them
                    5. If the information in the sections is insufficient, clearly state what's missing""".formatted(expertSystem.getName(),expertSystem.getDescription());

            // Build conversation history including document context
            ArrayNode contents = requestBody.putArray("contents");

            // Add system message first
            ObjectNode systemMessage = objectMapper.createObjectNode();
            systemMessage.put("role", "user");

            ArrayNode systemParts = systemMessage.putArray("parts");
            ObjectNode systemTextPart = objectMapper.createObjectNode();
            systemTextPart.put("text", systemPrompt);
            systemParts.add(systemTextPart);

            contents.add(systemMessage);

            // Add model response to system message
            ObjectNode modelSystemResponse = objectMapper.createObjectNode();
            modelSystemResponse.put("role", "model");

            ArrayNode modelSystemParts = modelSystemResponse.putArray("parts");
            ObjectNode modelSystemTextPart = objectMapper.createObjectNode();
            modelSystemTextPart.put("text", "I understand. I will answer based on the document sections you provide, use conversation history for context, synthesize information when needed, and indicate when information is insufficient.");
            modelSystemParts.add(modelSystemTextPart);

            contents.add(modelSystemResponse);

            // Add previous conversation messages if available
            if (previousMessages != null && !previousMessages.isEmpty()) {
                for (ConversationMessage message : previousMessages) {
                    ObjectNode messageNode = objectMapper.createObjectNode();
                    messageNode.put("role", message.isUser() ? "user" : "model");

                    ArrayNode messageParts = messageNode.putArray("parts");
                    ObjectNode textPart = objectMapper.createObjectNode();
                    textPart.put("text", message.getContent());
                    messageParts.add(textPart);
                    contents.add(messageNode);
                }
            }

            // Prepare user query with document sections
            ObjectNode userMessage = objectMapper.createObjectNode();
            userMessage.put("role", "user");

            ArrayNode userParts = userMessage.putArray("parts");
            ObjectNode userTextPart = objectMapper.createObjectNode();

            // Format document sections
            StringBuilder documentContext = new StringBuilder();
            documentContext.append("Here are relevant document sections:\n\n");

            for (SearchResult section : documentSections) {
                if (section.getTitle() != null && !section.getTitle().isEmpty()) {
                    documentContext.append("Title: ").append(section.getTitle()).append("\n");
                }
                documentContext.append("Content: ").append(section.getContent()).append("\n\n");
            }

            documentContext.append("User query: ").append(query);
            userTextPart.put("text", documentContext.toString());
            userParts.add(userTextPart);

            contents.add(userMessage);

            // Add generation parameters
            ObjectNode generationConfig = requestBody.putObject("generationConfig");
            generationConfig.put("temperature", 0.2);
            generationConfig.put("topP", 0.95);
            generationConfig.put("topK", 40);
            generationConfig.put("maxOutputTokens", 2048);

            // Make the API call
            String responseBody = webClient.post()
                    .uri(endpoint)
                    .bodyValue(requestBody)
                    .retrieve()
                    .bodyToMono(String.class)
                    .block();

            if (responseBody != null) {
                JsonNode responseJson = objectMapper.readTree(responseBody);

                // Extract the generated text from response
                return responseJson
                        .path("candidates")
                        .path(0)
                        .path("content")
                        .path("parts")
                        .path(0)
                        .path("text")
                        .asText();
            } else {
                throw new RuntimeException("Empty response from Gemini API");
            }
        } catch (Exception e) {
            logger.error("Failed to send message to Gemini: {}", e.getMessage());
            throw new RuntimeException("Failed to send message to Gemini: " + e.getMessage(), e);
        }
    }
}