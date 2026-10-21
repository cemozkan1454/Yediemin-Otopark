package com.yediemin.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import com.yediemin.backend.enums.AracTuru;
import com.yediemin.backend.enums.CekildigiBirim;


import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class AracDto {

    private UUID publicId;

    private String plaka;

    private String marka;

    private String model;

    private String renk;

    @NotNull(message = "Araç türü boş bırakılamaz")
    private AracTuru aracTuru;

    @NotNull(message = "Çekildiği birim boş bırakılamaz")
    private CekildigiBirim cekildigiBirim;

    @NotBlank(message = "Çekici boş bırakılamaz")
    private String cekiciFirma;

    @NotNull(message = "Çekici ücreti boş bırakılamaz")
    private BigDecimal cekiciUcreti;

    private String tutanakNo;

    @NotNull(message = "Anahtar bilgisi boş bırakılamaz")
    private Boolean anahtarVarMi;

    @NotNull(message = "Giriş tarihi boş bırakılamaz")
    private LocalDateTime girisTarihi;

    private LocalDateTime cikisTarihi;

    @NotBlank(message = "Yakalanma sebebi boş bırakılamaz")
    private String sebep;

    private String aciklama;

    private Boolean cekiciyeOdendiMi;

    private String kapakFotografi;
}
