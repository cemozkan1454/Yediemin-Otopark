package com.yediemin.backend.entity;

import com.yediemin.backend.enums.AracTuru;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "tarife")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Tarife {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private AracTuru aracTuru;

    @Column(nullable = false)
    private BigDecimal gunlukUcret;

}