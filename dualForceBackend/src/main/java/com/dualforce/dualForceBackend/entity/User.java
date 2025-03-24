package com.dualforce.dualForceBackend.entity;

import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.Getter;
import lombok.NonNull;
import lombok.Setter;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Setter
@Getter
@Document(collection = "users")
public class User {
    @Id
    private ObjectId id;
    @Indexed(unique = true)
    @NonNull
    private String email;
    @NonNull
    private String password;
    @NonNull
    private LocalDateTime createdAt;

    @DBRef
    @JsonManagedReference // Manages the forward part of the relationship
    private List<ExpertSystem> expertSystems = new ArrayList<>();
}