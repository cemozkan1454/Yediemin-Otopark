package com.yediemin.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import com.yediemin.backend.enums.AracTuru;
import com.yediemin.backend.enums.CekildigiBirim;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;



import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "arac")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Arac {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String plaka;

    private String marka;

    private String model;

    private String renk;

    @Enumerated(EnumType.STRING)
    private AracTuru aracTuru;

    private String sebep;

    @Enumerated(EnumType.STRING)
    private CekildigiBirim cekildigiBirim;

    private String cekiciFirma;

    private BigDecimal cekiciUcreti;

    private Boolean cekiciyeOdendiMi;

    private String tutanakNo;

    private Boolean anahtarVarMi;

    private LocalDateTime girisTarihi;

    private LocalDateTime cikisTarihi;

    @Column(precision = 10, scale = 2)
    private BigDecimal otoparkUcreti;

    @Column(precision = 10, scale = 2)
    private BigDecimal toplamUcret;

    public enum Durum {
        ICERIDE,
        CIKTI
    }
    @Enumerated(EnumType.STRING)
    private Durum durum;

    @Column(length = 1000)
    private String aciklama;

    @OneToMany(mappedBy = "arac",
            cascade = CascadeType.ALL,
            orphanRemoval = true)
    @JsonIgnore
    private List<Fotograf> fotograflar = new ArrayList<>();

    @Column(unique = true, nullable = false, updatable = false)
    private UUID publicId = UUID.randomUUID();
}