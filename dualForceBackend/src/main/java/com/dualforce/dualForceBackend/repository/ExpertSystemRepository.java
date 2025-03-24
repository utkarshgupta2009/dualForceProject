package com.dualforce.dualForceBackend.repository;

import com.dualforce.dualForceBackend.entity.ExpertSystem;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ExpertSystemRepository extends MongoRepository<ExpertSystem,String>{

    ExpertSystem findExpertSystemById(String id);
}
