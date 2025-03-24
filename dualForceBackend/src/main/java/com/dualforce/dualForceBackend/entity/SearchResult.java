package com.dualforce.dualForceBackend.entity;


import lombok.Getter;
import lombok.Setter;
import org.bson.types.ObjectId;

@Setter
@Getter
public class SearchResult {
    private ObjectId documentId;
    private ObjectId chunkId;
    private String content;
    private String title;
    private String summary;
    private String source;
    private double score;

    public SearchResult() {
    }

}
