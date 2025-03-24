package com.dualforce.dualForceBackend.dto;

import com.dualforce.dualForceBackend.entity.ExpertSystem;
import com.dualforce.dualForceBackend.entity.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private String id;
    private String email;
    private LocalDateTime createdAt;
    private List<ExpertSystemDTO> expertSystems;

    public static UserDTO fromEntity(User user) {
        if (user == null) {
            return null;
        }

        List<ExpertSystemDTO> expertSystemDTOs = null;
        if (user.getExpertSystems() != null) {
            expertSystemDTOs = user.getExpertSystems().stream()
                    .map(ExpertSystemDTO::fromEntity)
                    .collect(Collectors.toList());
        }

        return UserDTO.builder()
                .id(user.getId() != null ? user.getId().toString() : null)
                .email(user.getEmail())
                .createdAt(user.getCreatedAt())
                .expertSystems(expertSystemDTOs)
                .build();
    }
}