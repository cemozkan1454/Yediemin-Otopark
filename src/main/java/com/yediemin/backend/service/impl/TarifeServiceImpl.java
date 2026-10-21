package com.yediemin.backend.service.impl;

import com.yediemin.backend.entity.Tarife;
import com.yediemin.backend.repository.TarifeRepository;
import com.yediemin.backend.service.TarifeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TarifeServiceImpl implements TarifeService {

    private final TarifeRepository tarifeRepository;

    @Override
    public List<Tarife> tumTarifeleriGetir() {
        return tarifeRepository.findAll();
    }

    @Override
    public Tarife tarifeGetir(Long id) {
        return tarifeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tarife bulunamadı."));
    }
    public Tarife tarifeGuncelle(Long id, Tarife tarife) {

        Tarife mevcutTarife = tarifeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tarife bulunamadı."));

        mevcutTarife.setAracTuru(tarife.getAracTuru());
        mevcutTarife.setGunlukUcret(tarife.getGunlukUcret());

        return tarifeRepository.save(mevcutTarife);
    }
}