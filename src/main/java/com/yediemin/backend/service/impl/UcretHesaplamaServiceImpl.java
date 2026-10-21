package com.yediemin.backend.service.impl;

import com.yediemin.backend.entity.Arac;
import com.yediemin.backend.entity.Tarife;
import com.yediemin.backend.repository.TarifeRepository;
import com.yediemin.backend.service.UcretHesaplamaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Service
@RequiredArgsConstructor
public class UcretHesaplamaServiceImpl implements UcretHesaplamaService {

    private final TarifeRepository tarifeRepository;

    @Override
    public BigDecimal hesaplaToplamUcret(Arac arac, LocalDateTime cikisTarihi) {

        if (arac.getGirisTarihi() == null) {
            throw new RuntimeException("Araç giriş tarihi bulunamadı.");
        }

        if (cikisTarihi == null) {
            throw new RuntimeException("Çıkış tarihi boş bırakılamaz.");
        }

        if (cikisTarihi.isBefore(arac.getGirisTarihi())) {
            throw new RuntimeException("Çıkış tarihi giriş tarihinden önce olamaz.");
        }

        Tarife tarife = tarifeRepository.findByAracTuru(arac.getAracTuru())
                .orElseThrow(() -> new RuntimeException("Tarife bulunamadı."));

        long gunSayisi = ChronoUnit.DAYS.between(
                arac.getGirisTarihi(),
                cikisTarihi
        ) + 1;


        return tarife.getGunlukUcret()
                .multiply(BigDecimal.valueOf(gunSayisi));
    }
}