package com.dualforce.dualForceBackend.entity;

import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
import com.fasterxml.jackson.annotation.JsonBackReference;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Document(collection = "expert_system")
public class ExpertSystem {
    @Id
    private ObjectId id;

    private String name;

    private String description;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @DBRef
    private DocumentMetadata documentMetadata;

    @DBRef
    @JsonBackReference // Prevents circular reference during serialization
    private User user;
}