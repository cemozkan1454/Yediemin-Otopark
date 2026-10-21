package com.yediemin.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "fotograf")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Fotograf {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String dosyaAdi;

    private String dosyaYolu;

    private LocalDateTime yuklenmeTarihi;

    private String cloudinaryPublicId; // Silme işlemi için

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "arac_id")
    @JsonIgnore
    private Arac arac;
}