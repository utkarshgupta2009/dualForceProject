package com.dualforce.dualForceBackend.controller;

import com.dualforce.dualForceBackend.dto.ExpertSystemDTO;
import com.dualforce.dualForceBackend.entity.ApiResponse;
import com.dualforce.dualForceBackend.entity.ConversationMessage;
import com.dualforce.dualForceBackend.entity.ExpertSystem;
import com.dualforce.dualForceBackend.service.DocumentEmbeddingService;
import com.dualforce.dualForceBackend.service.ExpertSystemService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/expertSystem")
public class ExpertSystemController {
    private final ExpertSystemService expertSystemService;

    private static final Logger logger = LoggerFactory.getLogger(DocumentEmbeddingService.class);

    @Autowired
    public ExpertSystemController(ExpertSystemService expertSystemService) {
        this.expertSystemService = expertSystemService;
    }

    @PostMapping(value = "/create", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ExpertSystemDTO> >createExpertSystem(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "autoTruncate", defaultValue = "true") boolean autoTruncate,
            @RequestParam(value = "userId")String userId,
            @RequestParam(value = "name")String name,
            @RequestParam(value = "description")String description){

        try {
            // Check if file is empty
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(new ApiResponse<>("error", "File cannot be empty", null));
            }

            // Check file type
            String contentType = file.getContentType();
            if (contentType == null || !contentType.equals("application/pdf")) {
                return ResponseEntity.status(HttpStatus.UNSUPPORTED_MEDIA_TYPE)
                        .body(new ApiResponse<>("error", "Only PDF files are supported", null));
            }

            ExpertSystem expertSystemResponse = expertSystemService.CreateExpertSystem(
                    file, userId, name,description, autoTruncate
            );

            return ResponseEntity.ok(new ApiResponse<>("ok", "Successfully created bot", ExpertSystemDTO.fromEntity(expertSystemResponse)));

        } catch (IOException e) {
            logger.info(e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Failed to process document: " + e.getMessage(), null));
        }
    }

    @PostMapping("sendMessage")
    public ResponseEntity<ApiResponse<Map<String,Object>>> sendMessage(
            @RequestParam String expertSystemId,
            @RequestParam String query,
            @RequestParam(value = "limit", defaultValue = "5") int limit,
            @RequestBody List<ConversationMessage> conversationMessages){

        try {
          final String response =  expertSystemService.sendMessage(
                    expertSystemId,query,conversationMessages,limit
            );
          final Map<String, Object> res = new HashMap<>();
          res.put("response",response);
            return ResponseEntity.ok(new ApiResponse<>("ok", "Successfully received response", res));



        }catch (Exception e){
            logger.info(e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse<>("error", "Failed to process document: " + e.getMessage(), null));
        }



    }
}
