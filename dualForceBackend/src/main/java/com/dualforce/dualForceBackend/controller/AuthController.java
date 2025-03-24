package com.dualforce.dualForceBackend.controller;

import com.dualforce.dualForceBackend.dto.UserDTO;
import com.dualforce.dualForceBackend.entity.ApiResponse;
import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.service.AuthService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Optional;

@RestController
@RequestMapping("api/auth")
public class AuthController {

    @Autowired
    private AuthService authService;
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @PostMapping("/signup")
    public ResponseEntity<ApiResponse<UserDTO>> signUp(@RequestBody User user) {
        Optional<User> userAlreadyExists = authService.isExistingUser(user.getEmail());

        if (userAlreadyExists.isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ApiResponse<>("error", "Email Already registered", null));
        }


        User userCreated = authService.signUp(user);

        // Convert to DTO to avoid circular reference issues
        UserDTO userDTO = UserDTO.fromEntity(userCreated);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>("ok", "Successfully created account", userDTO));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<UserDTO>> login(@RequestBody User user) {
        Optional<User> isValidUser = authService.login(user);

        return isValidUser.map(value -> {
            UserDTO userDTO = UserDTO.fromEntity(value);
            return ResponseEntity.ok(new ApiResponse<>("ok", "Successfully logged in", userDTO));
        }).orElseGet(() -> ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ApiResponse<>("error", "Invalid Credentials", null)));
    }
}