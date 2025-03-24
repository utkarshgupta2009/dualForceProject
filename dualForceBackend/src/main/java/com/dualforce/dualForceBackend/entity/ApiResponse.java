package com.dualforce.dualForceBackend.entity;



import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Setter
@Getter
public class ApiResponse<T> {
    private String status;
    private String message;
    private T data;

    public ApiResponse(String status, String message, T data) {
        this.status = status;
        this.message = message;
        this.data = data;
    }

}