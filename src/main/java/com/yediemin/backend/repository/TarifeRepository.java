package com.yediemin.backend.repository;

import com.yediemin.backend.entity.Tarife;
import com.yediemin.backend.enums.AracTuru;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TarifeRepository extends JpaRepository<Tarife, Long> {

    Optional<Tarife> findByAracTuru(AracTuru aracTuru);

}