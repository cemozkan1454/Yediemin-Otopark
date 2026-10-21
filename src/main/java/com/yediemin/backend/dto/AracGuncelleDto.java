package com.yediemin.backend.dto;

import com.yediemin.backend.enums.AracTuru;
import com.yediemin.backend.enums.CekildigiBirim;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class AracGuncelleDto {

    private String plaka;

    private String marka;

    private String model;

    private String renk;

    private AracTuru aracTuru;

    private CekildigiBirim cekildigiBirim;

    private String sebep;


    private String cekiciFirma;

    private BigDecimal cekiciUcreti;

    private String tutanakNo;

    private Boolean anahtarVarMi;

    private String aciklama;
}