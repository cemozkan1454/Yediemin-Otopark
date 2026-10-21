package com.yediemin.backend.service;
import com.yediemin.backend.dto.AracCikisDto;
import java.math.BigDecimal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;


import com.yediemin.backend.dto.AracDetayDto;
import com.yediemin.backend.dto.CekiciOdemeDto;
import com.yediemin.backend.entity.Arac;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public interface AracService {

    Arac aracKaydet(Arac arac);

    Page<Arac> araclariGetir(Pageable pageable);

    List<Arac> tumAraclariGetir();

    Arac aracGetir(Long id);

    void aracSil(Long id);

    Arac aracGuncelle(Long id, Arac arac);

    Arac aracCikisiYap(Long id, AracCikisDto dto);

    Arac plakaIleGetir(String plaka);

    Page<Arac> iceridekiAraclariGetir(Pageable pageable);

    Page<Arac> cikanAraclariGetir(Pageable pageable);

    Arac cekiciOdemeDurumuGuncelle(Long id, CekiciOdemeDto dto);

    AracDetayDto detayGetir(UUID publicId);

    AracDetayDto cikisUcretiHesapla(UUID publicId);

    Arac cikisiGeriAl(Long id);

    Page<Arac> plakaIleAra(String plaka, Pageable pageable);

    Page<Arac> sayfaliAraclariGetir(Pageable pageable);


}
