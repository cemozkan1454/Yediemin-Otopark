package com.yediemin.backend.dto;

import lombok.Data;
import java.util.UUID;

@Data
public class AracListeDto {

    private UUID publicId;

    private String plaka;

    private String marka;

    private String model;

    private String aracTuru;

    private String durum;

    private String kapakFotografi;

    private Long id;
}