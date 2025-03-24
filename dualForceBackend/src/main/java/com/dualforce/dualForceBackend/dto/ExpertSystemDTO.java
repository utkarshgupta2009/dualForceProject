package com.dualforce.dualForceBackend.dto;

import com.dualforce.dualForceBackend.entity.ExpertSystem;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ExpertSystemDTO {
    private String id;
    private String name;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private DocumentMetadataDTO documentMetadata;
    private String userId;

    public static ExpertSystemDTO fromEntity(ExpertSystem expertSystem) {
        if (expertSystem == null) {
            return null;
        }
        
        return ExpertSystemDTO.builder()
                .id(expertSystem.getId() != null ? expertSystem.getId().toString() : null)
                .name(expertSystem.getName())
                .description(expertSystem.getDescription())
                .createdAt(expertSystem.getCreatedAt())
                .updatedAt(expertSystem.getUpdatedAt())
                .documentMetadata(DocumentMetadataDTO.fromEntity(expertSystem.getDocumentMetadata()))
                .userId(expertSystem.getUser() != null ? expertSystem.getUser().getId().toString() : null)
                .build();
    }
}
