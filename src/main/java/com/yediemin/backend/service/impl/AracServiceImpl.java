package com.yediemin.backend.service.impl;

import com.yediemin.backend.dto.CekiciOdemeDto;
import com.yediemin.backend.entity.Arac;
import com.yediemin.backend.repository.AracRepository;
import com.yediemin.backend.service.AracService;
import com.yediemin.backend.service.UcretHesaplamaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.yediemin.backend.repository.FotografRepository;
import com.yediemin.backend.dto.AracDetayDto;
import com.yediemin.backend.dto.FotografDto;
import com.yediemin.backend.entity.Fotograf;
import com.yediemin.backend.mapper.AracMapper;
import java.time.ZoneId;


import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;

import com.yediemin.backend.dto.AracCikisDto;

@Service
@RequiredArgsConstructor
public class AracServiceImpl implements AracService {
    private final UcretHesaplamaService ucretHesaplamaService;
    private final AracRepository aracRepository;
    private final FotografRepository fotografRepository;


    @Override
    public Arac aracKaydet(Arac arac) {

        // Araç ilk kaydedildiğinde otomatik içeride olur.
        arac.setDurum(Arac.Durum.ICERIDE);

        // Çekiciye henüz ödeme yapılmadı.
        arac.setCekiciyeOdendiMi(false);

        return aracRepository.save(arac);
    }
    @Override
    public Page<Arac> araclariGetir(Pageable pageable) {
        return aracRepository.findAllByOrderByGirisTarihiDesc(pageable);
    }
    @Override
    public List<Arac> tumAraclariGetir() {
        return aracRepository.findAll();
    }

    @Override
    public Arac aracGetir(Long id) {
        return aracRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));
    }

    @Override
    public void aracSil(Long id) {

        Arac arac = aracRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        List<Fotograf> fotograflar =
                fotografRepository.findByAracId(id);

        for (Fotograf fotograf : fotograflar) {

            try {
                Path dosyaYolu = Paths.get(fotograf.getDosyaYolu());
                Files.deleteIfExists(dosyaYolu);

            } catch (IOException e) {
                throw new RuntimeException(
                        "Fotoğraf dosyası silinemedi: "
                                + fotograf.getDosyaYolu()
                );
            }
        }

        // Fotoğrafların DB kayıtlarını sil
        fotografRepository.deleteAll(fotograflar);

        // Araç klasörünü sil
        try {
            Path klasorYolu = Paths.get("uploads/" + id);
            Files.deleteIfExists(klasorYolu);

        } catch (IOException e) {
            throw new RuntimeException("Fotoğraf klasörü silinemedi.");
        }

        // Aracı sil
        aracRepository.delete(arac);
    }

    @Override
    public Arac aracGuncelle(Long id, Arac arac) {

        Arac mevcutArac = aracRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        mevcutArac.setPlaka(arac.getPlaka());
        mevcutArac.setMarka(arac.getMarka());
        mevcutArac.setModel(arac.getModel());
        mevcutArac.setRenk(arac.getRenk());
        mevcutArac.setAracTuru(arac.getAracTuru());
        mevcutArac.setSebep(arac.getSebep());
        mevcutArac.setCekildigiBirim(arac.getCekildigiBirim());
        mevcutArac.setCekiciFirma(arac.getCekiciFirma());
        mevcutArac.setCekiciUcreti(arac.getCekiciUcreti());
        mevcutArac.setTutanakNo(arac.getTutanakNo());
        mevcutArac.setAnahtarVarMi(arac.getAnahtarVarMi());
        mevcutArac.setAciklama(arac.getAciklama());

        return aracRepository.save(mevcutArac);
    }
    @Override
    public Arac aracCikisiYap(Long id, AracCikisDto dto) {

        Arac arac = aracRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Araç bulunamadı.")
                );

        if (arac.getDurum() == Arac.Durum.CIKTI) {
            throw new RuntimeException("Bu araç zaten otoparktan çıkmış.");
        }

        if (arac.getGirisTarihi() == null) {
            throw new RuntimeException("Araç giriş tarihi bulunamadı.");
        }

        if (dto.getCikisTarihi() == null) {
            throw new RuntimeException("Çıkış tarihi boş bırakılamaz.");
        }

        if (dto.getCikisTarihi().isBefore(arac.getGirisTarihi())) {
            throw new RuntimeException(
                    "Çıkış tarihi, giriş tarihinden önce olamaz."
            );
        }

        BigDecimal otoparkUcreti =
                ucretHesaplamaService.hesaplaToplamUcret(
                        arac,
                        dto.getCikisTarihi()
                );

        BigDecimal cekiciUcreti = arac.getCekiciUcreti();

        if (cekiciUcreti == null) {
            cekiciUcreti = BigDecimal.ZERO;
        }

        BigDecimal toplamUcret =
                otoparkUcreti.add(cekiciUcreti);

        arac.setCikisTarihi(dto.getCikisTarihi());
        arac.setOtoparkUcreti(otoparkUcreti);
        arac.setToplamUcret(toplamUcret);
        arac.setDurum(Arac.Durum.CIKTI);

        return aracRepository.save(arac);
    }
    @Override
    public Arac plakaIleGetir(String plaka) {
        return aracRepository.findByPlakaIgnoreCase(plaka)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));
    }
    @Override
    public Page<Arac> iceridekiAraclariGetir(Pageable pageable) {
        return aracRepository.findByDurumOrderByGirisTarihiDesc(
                Arac.Durum.ICERIDE,
                pageable
        );
    }
    @Override
    public Page<Arac> cikanAraclariGetir(Pageable pageable) {
        return aracRepository.findByDurumOrderByGirisTarihiDesc(
                Arac.Durum.CIKTI,
                pageable
        );
    }
    @Override
    public Arac cekiciOdemeDurumuGuncelle(Long id, CekiciOdemeDto dto) {

        Arac arac = aracRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        arac.setCekiciyeOdendiMi(dto.getCekiciyeOdendiMi());

        return aracRepository.save(arac);
    }
    @Override
    public AracDetayDto detayGetir(UUID publicId) {

        Arac arac = aracRepository.findByPublicId(publicId)
                .orElseThrow(() ->
                        new RuntimeException("Araç bulunamadı.")
                );

        AracDetayDto dto = AracMapper.toDetayDto(arac);

        List<Fotograf> fotograflar =
                fotografRepository.findByAracId(arac.getId());

        dto.setFotograflar(
                fotograflar.stream()
                        .map(fotograf -> {
                            FotografDto fotografDto = new FotografDto();
                            fotografDto.setId(fotograf.getId());
                            fotografDto.setUrl(
                                    "/fotograf/dosya/" + arac.getPublicId() + "/" + fotograf.getId()
                            );
                            fotografDto.setYuklenmeTarihi(fotograf.getYuklenmeTarihi());
                            return fotografDto;
                        })
                        .toList()
        );

        return dto;
    }
    @Override
    public AracDetayDto cikisUcretiHesapla(UUID publicId) {

        Arac arac = aracRepository.findByPublicId(publicId)
                .orElseThrow(() ->
                        new RuntimeException("Araç bulunamadı.")
                );

        if (arac.getDurum() == Arac.Durum.CIKTI) {
            throw new RuntimeException("Bu araç zaten çıkış yapmış.");
        }

        LocalDateTime cikisTarihi =
                LocalDateTime.now(ZoneId.of("Europe/Istanbul"));

        BigDecimal otoparkUcreti =
                ucretHesaplamaService.hesaplaToplamUcret(
                        arac,
                        cikisTarihi
                );

        BigDecimal cekiciUcreti = arac.getCekiciUcreti();

        if (cekiciUcreti == null) {
            cekiciUcreti = BigDecimal.ZERO;
        }

        BigDecimal toplamUcret =
                otoparkUcreti.add(cekiciUcreti);

        AracDetayDto dto = AracMapper.toDetayDto(arac);

        dto.setOtoparkUcreti(otoparkUcreti);
        dto.setToplamUcret(toplamUcret);

        return dto;
    }
    @Override
    public Arac cikisiGeriAl(Long id) {

        Arac arac = aracRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        if (arac.getDurum() != Arac.Durum.CIKTI) {
            throw new RuntimeException(
                    "Bu araç için geri alınacak bir çıkış işlemi yok."
            );
        }

        arac.setDurum(Arac.Durum.ICERIDE);
        arac.setCikisTarihi(null);
        arac.setOtoparkUcreti(null);
        arac.setToplamUcret(null);

        return aracRepository.save(arac);
    }
    @Override
    public Page<Arac> plakaIleAra(String plaka, Pageable pageable) {
        return aracRepository
                .findByPlakaContainingIgnoreCaseOrderByGirisTarihiDesc(
                        plaka,
                        pageable
                );
    }
    @Override
    public Page<Arac> sayfaliAraclariGetir(Pageable pageable) {
        return aracRepository.findAll(pageable);
    }



}
