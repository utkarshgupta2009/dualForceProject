package com.dualforce.dualForceBackend.repository;

import com.dualforce.dualForceBackend.entity.documentEntities.DocumentChunk;
import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
import com.dualforce.dualForceBackend.entity.documentEntities.EmbeddingDocument;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperationContext;
import org.springframework.data.mongodb.core.aggregation.AggregationOptions;
import org.springframework.data.mongodb.core.aggregation.AggregationResults;
import org.springframework.data.mongodb.core.aggregation.ProjectionOperation;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.stereotype.Repository;

import java.util.ArrayList;
import java.util.List;

@Repository
public class EmbeddingRepository {

    private static final Logger logger = LoggerFactory.getLogger(EmbeddingRepository.class);
    private final MongoTemplate mongoTemplate;

    @Autowired
    public EmbeddingRepository(MongoTemplate mongoTemplate) {
        this.mongoTemplate = mongoTemplate;
    }

    public DocumentMetadata saveDocumentMetadata(DocumentMetadata metadata) {
        return mongoTemplate.save(metadata);
    }

    public void saveEmbedding(String source, String content, List<Double> embedding, DocumentChunk metadata, String documentId) {
        try {
            // Create embedding document from chunk metadata and vector
            EmbeddingDocument embeddingDoc = new EmbeddingDocument(metadata, documentId, embedding);

            // Save to MongoDB
            mongoTemplate.save(embeddingDoc);

            logger.info("Saved embedding for chunk {} with {} dimensions", metadata.getIndex(), embedding.size());
        } catch (Exception e) {
            logger.error("Error saving embedding: {}", e.getMessage());
            throw new RuntimeException("Failed to save embedding", e);
        }
    }

    /**
     * Performs vector similarity search using cosine similarity
     * @param queryVector the embedding vector of the query
     * @param limit maximum number of results to return
     * @return list of most similar documents
     */
    public List<EmbeddingDocument> findSimilarDocuments(List<Double> queryVector, int limit) {
        try {
            // Create the aggregation pipeline using the Aggregation builder
            Aggregation aggregation = createVectorSearchAggregation(queryVector, limit);

            // Execute the aggregation
            AggregationResults<EmbeddingDocument> results = mongoTemplate.aggregate(
                    aggregation,
                    "embeddings",
                    EmbeddingDocument.class
            );

            logger.info("Vector search found {} results", results.getMappedResults().size());
            return results.getMappedResults();
        } catch (Exception e) {
            logger.error("Error during vector search: {}", e.getMessage(), e);
            return new ArrayList<>();
        }
    }

    private Aggregation createVectorSearchAggregation(List<Double> queryVector, int limit) {
        // For MongoDB Atlas Vector Search, you would use the appropriate stages
        // This is an example implementation - adjust according to your requirements

        // If using MongoDB Atlas Vector Search with $vectorSearch (MongoDB 5.0+)
        // You'll need to create a custom AggregationOperation for vectorSearch
        AggregationOperation vectorSearch = new AggregationOperation() {
            @Override
            public Document toDocument(AggregationOperationContext context) {
                Document vectorSearchDoc = new Document("$vectorSearch",
                        new Document("index", "vector_index")
                                .append("path", "embedding")
                                .append("queryVector", queryVector)
                                .append("numCandidates", limit * 10)
                                .append("limit", limit));
                return vectorSearchDoc;
            }
        };

        // For additional projection if needed
        ProjectionOperation projection = Aggregation.project()
                .and(context -> new Document("$meta", "vectorSearchScore")).as("score")
                .and("metadata").as("metadata")
                .and("documentId").as("documentId")
                .and("embedding").as("embedding");

        // Build the aggregation pipeline
        Aggregation aggregation = Aggregation.newAggregation(
                vectorSearch,
                projection,
                Aggregation.limit(limit)
        );

        // Enable disk use if needed
        AggregationOptions options = AggregationOptions.builder().allowDiskUse(true).build();
        aggregation = aggregation.withOptions(options);

        return aggregation;
    }

    public List<EmbeddingDocument> findByDocumentId(String documentId) {
        final DocumentMetadata document = mongoTemplate.findById(documentId,DocumentMetadata.class);
        Query query = new Query(Criteria.where("document").is(document));
        return mongoTemplate.find(query, EmbeddingDocument.class);
    }

    public void deleteByDocumentId(String documentId) {
        Query query = new Query(Criteria.where("documentId").is(documentId));
        mongoTemplate.remove(query, EmbeddingDocument.class);
        logger.info("Deleted embeddings for document {}", documentId);
    }
}