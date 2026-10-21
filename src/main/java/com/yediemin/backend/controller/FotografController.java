package com.yediemin.backend.controller;

import com.yediemin.backend.entity.Fotograf;
import com.yediemin.backend.service.FotografService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/fotograf")
@RequiredArgsConstructor
public class FotografController {

    private final FotografService fotografService;


    @PostMapping("/yukle/{aracPublicId}")
    public ResponseEntity<Void> fotografYukle(
            @PathVariable UUID aracPublicId,
            @RequestParam("dosya") MultipartFile dosya
    ) throws IOException {

        fotografService.fotografYukle(aracPublicId, dosya);

        return ResponseEntity.ok().build();
    }


    @GetMapping("/{aracPublicId}")
    public ResponseEntity<List<Fotograf>> fotograflariGetir(
            @PathVariable UUID aracPublicId
    ) {
        return ResponseEntity.ok(
                fotografService.fotograflariGetir(aracPublicId)
        );
    }

    @GetMapping("/dosya/{aracPublicId}/{fotografId}")
    public ResponseEntity<Void> fotografDosyasi(
            @PathVariable UUID aracPublicId,
            @PathVariable Long fotografId
    ) {

        Fotograf fotograf =
                fotografService.fotografGetir(aracPublicId, fotografId);

        if (fotograf.getDosyaYolu() == null ||
                !fotograf.getDosyaYolu().startsWith("http")) {

            return ResponseEntity.notFound().build();
        }

        return ResponseEntity
                .status(302)
                .header(HttpHeaders.LOCATION, fotograf.getDosyaYolu())
                .build();
    }


    @DeleteMapping("/arac/{aracPublicId}/{fotografId}")
    public ResponseEntity<Void> fotografSil(
            @PathVariable UUID aracPublicId,
            @PathVariable Long fotografId
    ) {

        fotografService.fotografSil(aracPublicId, fotografId);

        return ResponseEntity.noContent().build();
    }

}
