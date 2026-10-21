package com.yediemin.backend.repository;

import com.yediemin.backend.entity.Arac;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface AracRepository extends JpaRepository<Arac, Long> {
    Optional<Arac> findByPlakaIgnoreCase(String plaka);
    Optional<Arac> findByPublicId(UUID publicId);
    List<Arac> findByDurum(Arac.Durum durum);
    Page<Arac> findAllByOrderByGirisTarihiDesc(Pageable pageable);
    Page<Arac> findByDurumOrderByGirisTarihiDesc(
            Arac.Durum durum,
            Pageable pageable
    );
    Page<Arac> findByPlakaContainingIgnoreCaseOrderByGirisTarihiDesc(
            String plaka,
            Pageable pageable
    );
    long countByDurum(Arac.Durum durum);

    long countByGirisTarihiGreaterThanEqualAndGirisTarihiLessThan(
            LocalDateTime baslangic,
            LocalDateTime bitis
    );

    long countByCikisTarihiGreaterThanEqualAndCikisTarihiLessThan(
            LocalDateTime baslangic,
            LocalDateTime bitis
    );


}

