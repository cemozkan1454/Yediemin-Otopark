package com.yediemin.backend.controller;

import com.yediemin.backend.dto.*;
import com.yediemin.backend.entity.Arac;
import com.yediemin.backend.mapper.AracMapper;
import com.yediemin.backend.service.AracService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/arac")
@RequiredArgsConstructor
public class AracController {

    private final AracService aracService;

    @PostMapping
    public AracDto aracKaydet(@Valid @RequestBody AracDto dto) {

        Arac arac = AracMapper.toEntity(dto);

        Arac kaydedilenArac = aracService.aracKaydet(arac);

        return AracMapper.toDto(kaydedilenArac);
    }
    @GetMapping
    public Page<AracDto> araclariGetir(Pageable pageable) {

        return aracService.araclariGetir(pageable)
                .map(AracMapper::toDto);
    }

    @GetMapping("/tum")
    public List<AracDto> tumAraclariGetir() {

        return aracService.tumAraclariGetir()
                .stream()
                .map(AracMapper::toDto)
                .toList();
    }

    @GetMapping("/{id}")
    public AracDto aracGetir(@PathVariable Long id) {

        Arac arac = aracService.aracGetir(id);

        return AracMapper.toDto(arac);
    }

    @PutMapping("/{id}")
    public AracDto aracGuncelle(
            @PathVariable Long id,
            @RequestBody AracGuncelleDto dto) {

        Arac arac = new Arac();

        arac.setPlaka(dto.getPlaka());
        arac.setMarka(dto.getMarka());
        arac.setModel(dto.getModel());
        arac.setRenk(dto.getRenk());
        arac.setAracTuru(dto.getAracTuru());
        arac.setSebep(dto.getSebep());
        arac.setCekildigiBirim(dto.getCekildigiBirim());
        arac.setCekiciFirma(dto.getCekiciFirma());
        arac.setCekiciUcreti(dto.getCekiciUcreti());
        arac.setTutanakNo(dto.getTutanakNo());
        arac.setAnahtarVarMi(dto.getAnahtarVarMi());
        arac.setAciklama(dto.getAciklama());

        Arac guncellenenArac =
                aracService.aracGuncelle(id, arac);

        return AracMapper.toDto(guncellenenArac);
    }

    @DeleteMapping("/{id}")
    public void aracSil(@PathVariable Long id) {
        aracService.aracSil(id);
    }

    @PutMapping("/{id}/cikis")
    public AracDetayDto aracCikisiYap(
            @PathVariable Long id,
            @Valid @RequestBody AracCikisDto dto) {

        Arac arac = aracService.aracCikisiYap(id, dto);

        return AracMapper.toDetayDto(arac);
    }

    @GetMapping("/plaka/{plaka}")
    public AracDto plakaIleGetir(
            @PathVariable String plaka) {

        Arac arac = aracService.plakaIleGetir(plaka);

        return AracMapper.toDto(arac);
    }

    @GetMapping("/iceride")
    public Page<AracDto> iceridekiAraclariGetir(Pageable pageable) {

        return aracService.iceridekiAraclariGetir(pageable)
                .map(AracMapper::toDto);
    }

    @GetMapping("/cikti")
    public Page<AracDto> cikanAraclariGetir(Pageable pageable) {

        return aracService.cikanAraclariGetir(pageable)
                .map(AracMapper::toDto);
    }

    @PutMapping("/{id}/cekici-odeme")
    public AracDto cekiciOdemeDurumuGuncelle(
            @PathVariable Long id,
            @Valid @RequestBody CekiciOdemeDto dto) {

        Arac arac =
                aracService.cekiciOdemeDurumuGuncelle(id, dto);

        return AracMapper.toDto(arac);
    }

    @GetMapping("/liste")
    public Page<AracListeDto> listeGetir(Pageable pageable) {

        return aracService.araclariGetir(pageable)
                .map(AracMapper::toListeDto);
    }

    @GetMapping("/detay/{publicId}")
    public AracDetayDto detayGetir(
            @PathVariable UUID publicId) {

        return aracService.detayGetir(publicId);
    }

    @GetMapping("/{publicId}/cikis-ucreti")
    public AracDetayDto cikisUcretiHesapla(
            @PathVariable UUID publicId) {

        return aracService.cikisUcretiHesapla(publicId);
    }
    @PutMapping("/{id}/cikis-geri-al")
    public AracDto cikisiGeriAl(@PathVariable Long id) {

        Arac arac = aracService.cikisiGeriAl(id);

        return AracMapper.toDto(arac);
    }
    @GetMapping("/liste/sayfali")
    public Page<AracListeDto> listeSayfali(
            @RequestParam(defaultValue = "0") int sayfa,
            @RequestParam(defaultValue = "20") int boyut) {

        Pageable pageable = PageRequest.of(
                sayfa,
                boyut
        );

        return aracService.araclariGetir(pageable)
                .map(AracMapper::toListeDto);
    }
    @GetMapping("/iceride/sayfali")
    public Page<AracListeDto> icerideSayfali(
            @RequestParam(defaultValue = "0") int sayfa,
            @RequestParam(defaultValue = "20") int boyut) {

        Pageable pageable = PageRequest.of(sayfa, boyut);

        return aracService.iceridekiAraclariGetir(pageable)
                .map(AracMapper::toListeDto);
    }
    @GetMapping("/cikti/sayfali")
    public Page<AracListeDto> ciktiSayfali(
            @RequestParam(defaultValue = "0") int sayfa,
            @RequestParam(defaultValue = "20") int boyut) {

        Pageable pageable = PageRequest.of(sayfa, boyut);

        return aracService.cikanAraclariGetir(pageable)
                .map(AracMapper::toListeDto);
    }
    @GetMapping("/ara")
    public Page<AracListeDto> aracAra(
            @RequestParam String plaka,
            Pageable pageable) {

        return aracService.plakaIleAra(plaka, pageable)
                .map(AracMapper::toListeDto);
    }


}