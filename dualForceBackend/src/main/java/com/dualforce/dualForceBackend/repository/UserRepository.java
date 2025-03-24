package com.dualforce.dualForceBackend.repository;

import com.dualforce.dualForceBackend.entity.User;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UserRepository extends MongoRepository<User,String> {


    User findUserById(String id);
}
