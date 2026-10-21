package com.yediemin.backend.controller;

import com.yediemin.backend.entity.Tarife;
import com.yediemin.backend.service.TarifeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tarife")
@RequiredArgsConstructor
public class TarifeController {

    private final TarifeService tarifeService;

    @GetMapping
    public List<Tarife> tumTarifeleriGetir() {

        return tarifeService.tumTarifeleriGetir();

    }

    @PutMapping("/{id}")
    public Tarife tarifeGuncelle(@PathVariable Long id,
                                 @RequestBody Tarife tarife) {

        return tarifeService.tarifeGuncelle(id, tarife);
    }

}