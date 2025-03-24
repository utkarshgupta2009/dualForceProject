package com.dualforce.dualForceBackend.entity.documentEntities;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.time.LocalDateTime;
import java.util.List;

@Setter
@Getter
@Document(collection = "embeddings")
@Data
public class EmbeddingDocument {

    @Id
    private ObjectId id;


    private String documentId;

    private String content;
    private int chunkIndex;
    private String title;
    private String summary;
    private String source;
    private int tokenCount;
    private boolean overlap;
    private List<Double> vector;
    private LocalDateTime createdAt;

    public EmbeddingDocument() {
        this.createdAt = LocalDateTime.now();
    }

    // Constructor to create from DocumentChunk
    public EmbeddingDocument(DocumentChunk chunk, String documentId, List<Double> vector) {
        this();
        this.documentId = documentId;  // Now using the DocumentMetadata object directly
        this.content = chunk.getContent();
        this.chunkIndex = chunk.getIndex();
        this.title = chunk.getTitle();
        this.summary = chunk.getSummary();
        this.source = chunk.getSource();
        this.tokenCount = chunk.getTokenCount();
        this.overlap = chunk.isOverlap();
        this.vector = vector;
    }
}