package com.dualforce.dualForceBackend.entity.documentEntities;

import com.dualforce.dualForceBackend.entity.ExpertSystem;
import com.dualforce.dualForceBackend.entity.User;
import lombok.Getter;
import lombok.Setter;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Setter
@Getter
@Document(collection = "document_metadata")
public class DocumentMetadata {
    @Id
    private ObjectId id;

    private String filename;
    private String contentType;
    private long sizeBytes;
    private int totalChunks;
    private LocalDateTime createdAt;



    public DocumentMetadata() {
        this.createdAt = LocalDateTime.now();
    }


}
