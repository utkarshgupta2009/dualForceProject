package com.dualforce.dualForceBackend.repository;

import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.service.DocumentEmbeddingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;
import java.util.OptionalInt;

public interface AuthRepository extends MongoRepository<User,String> {
    static final Logger logger = LoggerFactory.getLogger(AuthRepository.class);

    Optional<User> findByEmailAndPassword(String email, String Password);
    Optional<User> findByEmail(String email);
}
