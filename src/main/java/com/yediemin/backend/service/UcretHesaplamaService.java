package com.yediemin.backend.service;

import com.yediemin.backend.entity.Arac;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public interface UcretHesaplamaService {

    BigDecimal hesaplaToplamUcret(Arac arac, LocalDateTime cikisTarihi);

}