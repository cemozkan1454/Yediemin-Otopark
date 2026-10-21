package com.yediemin.backend.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FotografDto {
    private Long id;
    private String url;
    private LocalDateTime yuklenmeTarihi;
}
