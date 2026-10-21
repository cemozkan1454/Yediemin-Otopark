package com.yediemin.backend.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
public class AracDetayDto {

    private Long id;
    private UUID publicId;

    // Araç bilgileri
    private String plaka;
    private String marka;
    private String model;
    private String renk;
    private String aracTuru;
    private String durum;


    // Çekici bilgileri
    private String cekiciFirma;
    private BigDecimal cekiciUcreti;
    private Boolean cekiciyeOdendiMi;

    private String tutanakNo;
    private String cekildigiBirim;
    private String sebep;
    private Boolean anahtarVarMi;

    // Giriş / çıkış
    private LocalDateTime girisTarihi;
    private LocalDateTime cikisTarihi;

    //Ücretler
    private BigDecimal otoparkUcreti;
    private BigDecimal toplamUcret;

    //Acıklama
    private String aciklama;

    //Fotoğraflar
    private List<FotografDto> fotograflar;
}
