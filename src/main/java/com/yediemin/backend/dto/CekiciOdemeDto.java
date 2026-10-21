package com.yediemin.backend.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CekiciOdemeDto {

    @NotNull(message = "Çekici ödeme durumu boş bırakılamaz")
    private Boolean cekiciyeOdendiMi;
}