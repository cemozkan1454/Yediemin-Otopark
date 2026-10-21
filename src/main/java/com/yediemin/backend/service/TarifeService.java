package com.yediemin.backend.service;

import com.yediemin.backend.entity.Tarife;

import java.util.List;

public interface TarifeService {

    List<Tarife> tumTarifeleriGetir();

    Tarife tarifeGetir(Long id);

    Tarife tarifeGuncelle(Long id, Tarife tarife);

}