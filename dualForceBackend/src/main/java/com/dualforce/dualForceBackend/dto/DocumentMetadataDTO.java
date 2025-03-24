package com.dualforce.dualForceBackend.dto;

import com.dualforce.dualForceBackend.entity.documentEntities.DocumentMetadata;
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
public class DocumentMetadataDTO {
    private String id;
    private String filename;
    private String contentType;
    private long sizeBytes;
    private int totalChunks;
    private LocalDateTime createdAt;

    public static DocumentMetadataDTO fromEntity(DocumentMetadata documentMetadata) {
        if (documentMetadata == null) {
            return null;
        }
        
        return DocumentMetadataDTO.builder()
                .id(documentMetadata.getId() != null ? documentMetadata.getId().toString() : null)
                .filename(documentMetadata.getFilename())
                .contentType(documentMetadata.getContentType())
                .sizeBytes(documentMetadata.getSizeBytes())
                .totalChunks(documentMetadata.getTotalChunks())
                .createdAt(documentMetadata.getCreatedAt())
                .build();
    }
}
