package com.yediemin.backend.service;

import com.yediemin.backend.entity.Fotograf;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.UUID;

public interface FotografService {

    Fotograf fotografYukle(UUID aracPublicId, MultipartFile dosya)
            throws IOException;

    List<Fotograf> fotograflariGetir(UUID aracPublicId);

    Fotograf fotografGetir(UUID aracPublicId, Long fotografId);

    void fotografSil(UUID aracPublicId, Long fotografId);
}
