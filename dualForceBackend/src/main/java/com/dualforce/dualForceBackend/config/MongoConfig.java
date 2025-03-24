//package com.dualforce.dualForceBackend.config;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.data.domain.Sort;
//import org.springframework.data.mongodb.core.MongoTemplate;
//import org.springframework.data.mongodb.core.index.Index;
//import org.springframework.data.mongodb.core.index.IndexOperations;
//import org.bson.Document;
//
//import javax.annotation.PostConstruct;
//
//@Configuration
//public class MongoConfig {
//
//    @Autowired
//    private MongoTemplate mongoTemplate;
//
//    @Value("${vector.embedding.dimensions:768}")
//    private int embeddingDimensions;
//
//    /**
//     * Creates all necessary indexes including vector search index for the embeddings collection
//     * This runs automatically on application startup
//     */
//    @PostConstruct
//    public void initVectorIndexes() {
//        // Collection name is based on the EmbeddingDocument entity
//        String collectionName = "embeddings";
//
//        // Get the collection's index operations
//        IndexOperations indexOps = mongoTemplate.indexOps(collectionName);
//
//        // Create standard indexes for better query performance
//        indexOps.ensureIndex(new Index().on("document", Sort.Direction.ASC));
//        indexOps.ensureIndex(new Index().on("source", Sort.Direction.ASC).sparse());
//        indexOps.ensureIndex(new Index().on("document", Sort.Direction.ASC)
//                .on("chunkIndex", Sort.Direction.ASC));
//
//        // Define the vector search index specifically for the 'vector' field in EmbeddingDocument
//        Document vectorSearchIndex = new Document()
//                .append("mappings", new Document()
//                        .append("dynamic", false)
//                        .append("fields", new Document()
//                                .append("vector", new Document()
//                                        .append("dimensions", embeddingDimensions)
//                                        .append("similarity", "cosine")
//                                        .append("type", "knnVector"))
//                                .append("document", new Document()
//                                        .append("type", "objectId"))
//                                .append("content", new Document()
//                                        .append("type", "string"))
//                                .append("title", new Document()
//                                        .append("type", "string"))
//                                .append("chunkIndex", new Document()
//                                        .append("type", "number"))));
//
//        // Create the vector search index using MongoDB command
//        // Note: This requires MongoDB Atlas with Vector Search capability
//        try {
//            mongoTemplate.getDb().runCommand(new Document()
//                    .append("createSearchIndex", collectionName)
//                    .append("name", "vector_index")
//                    .append("definition", vectorSearchIndex));
//
//            System.out.println("Vector search index created successfully on 'vector' field in 'embeddings' collection");
//        } catch (Exception e) {
//            System.err.println("Error creating vector search index: " + e.getMessage());
//            // Continue with application startup even if index creation fails
//        }
//    }
//}