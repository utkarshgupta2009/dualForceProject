package com.dualforce.dualForceBackend.entity.documentEntities;


import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class DocumentChunk {
    private String id;
    private String content;
    private int index;
    private String title;
    private String summary;
    private String source;
    private int tokenCount;
    private boolean overlap;

    public DocumentChunk() {

        this.overlap = false;
    }

}