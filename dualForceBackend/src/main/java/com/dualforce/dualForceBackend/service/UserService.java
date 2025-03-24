package com.dualforce.dualForceBackend.service;

import com.dualforce.dualForceBackend.entity.User;
import com.dualforce.dualForceBackend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public User getUserById(String userId){
        return userRepository.findUserById(userId);
    }

    public void updateUser(User user){
         userRepository.save(user);
    }
}
