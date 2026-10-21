package com.yediemin.backend.repository;

import com.yediemin.backend.entity.Fotograf;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;


public interface FotografRepository extends JpaRepository<Fotograf, Long> {

    List<Fotograf> findByAracId(Long aracId);

    long countByAracId(Long aracId);

    List<Fotograf> findByAracPublicId(UUID aracPublicId);
}