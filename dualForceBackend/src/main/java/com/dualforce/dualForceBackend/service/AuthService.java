package com.dualforce.dualForceBackend.service;

import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.repository.AuthRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Optional;

@Component
public class AuthService {
    private static final Logger logger = LoggerFactory.getLogger(AuthService.class);


    @Autowired
    private AuthRepository authRepository;

    public User signUp(User user){
        final LocalDateTime localDateTime = LocalDateTime.now();
        logger.info(localDateTime.toString());
        user.setCreatedAt(localDateTime);
       return authRepository.save(user);
    }

    public Optional<User> login(User user){

        return authRepository.findByEmailAndPassword(user.getEmail(), user.getPassword());
    }

    public Optional<User> isExistingUser(String email){
        return authRepository.findByEmail(email);
    }


}
