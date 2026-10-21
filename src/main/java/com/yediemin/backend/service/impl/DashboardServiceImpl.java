package com.yediemin.backend.service.impl;

import com.yediemin.backend.dto.DashboardOzetDto;
import com.yediemin.backend.entity.Arac;
import com.yediemin.backend.repository.AracRepository;
import com.yediemin.backend.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final AracRepository aracRepository;

    @Override
    public DashboardOzetDto ozetGetir() {

        LocalDateTime baslangic =
                LocalDate.now().atStartOfDay();

        LocalDateTime bitis =
                baslangic.plusDays(1);

        long iceride =
                aracRepository.findByDurum(Arac.Durum.ICERIDE).size();

        long bugunGiris =
                aracRepository
                        .countByGirisTarihiGreaterThanEqualAndGirisTarihiLessThan(
                                baslangic,
                                bitis
                        );

        long bugunCikis =
                aracRepository
                        .countByCikisTarihiGreaterThanEqualAndCikisTarihiLessThan(
                                baslangic,
                                bitis
                        );

        return new DashboardOzetDto(
                iceride,
                bugunGiris,
                bugunCikis
        );
    }
}