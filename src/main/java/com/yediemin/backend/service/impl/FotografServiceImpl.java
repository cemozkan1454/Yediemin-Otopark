package com.yediemin.backend.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.yediemin.backend.entity.Arac;
import com.yediemin.backend.entity.Fotograf;
import com.yediemin.backend.repository.AracRepository;
import com.yediemin.backend.repository.FotografRepository;
import com.yediemin.backend.service.FotografService;
import lombok.RequiredArgsConstructor;
import net.coobird.thumbnailator.Thumbnails;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FotografServiceImpl implements FotografService {

    private final FotografRepository fotografRepository;
    private final AracRepository aracRepository;
    private final Cloudinary cloudinary;

    @Override
    public Fotograf fotografYukle(
            UUID aracPublicId,
            MultipartFile dosya
    ) throws IOException {

        Arac arac = aracRepository.findByPublicId(aracPublicId)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        // Araç başına maksimum 8 fotoğraf
        if (fotografRepository.countByAracId(arac.getId()) >= 8) {
            throw new RuntimeException(
                    "Bir araç için en fazla 8 fotoğraf yüklenebilir."
            );
        }

        // Boş dosya kontrolü
        if (dosya.isEmpty()) {
            throw new RuntimeException("Fotoğraf boş olamaz.");
        }

        // 20 MB kontrolü
        if (dosya.getSize() > 20 * 1024 * 1024) {
            throw new RuntimeException(
                    "Fotoğraf boyutu en fazla 20 MB olabilir."
            );
        }

        // ============================================================
        // FOTOĞRAFI KÜÇÜLT + SIKIŞTIR
        // ============================================================

        ByteArrayOutputStream outputStream =
                new ByteArrayOutputStream();

        Thumbnails.of(dosya.getInputStream())
                .size(1920, 1920)
                .outputFormat("jpg")
                .outputQuality(0.82)
                .toOutputStream(outputStream);

        byte[] sikistirilmisFoto = outputStream.toByteArray();

        // ============================================================
        // CLOUDINARY'YE YÜKLE
        // ============================================================

        String klasor = "yediemin/arac-" + arac.getId();

        Map<?, ?> uploadResult = cloudinary.uploader().upload(
                sikistirilmisFoto,
                ObjectUtils.asMap(
                        "folder", klasor,
                        "resource_type", "image"
                )
        );

        String cloudinaryUrl =
                (String) uploadResult.get("secure_url");

        String cloudinaryPublicId =
                (String) uploadResult.get("public_id");

        // ============================================================
        // VERİTABANI KAYDI
        // ============================================================

        Fotograf fotograf = new Fotograf();

        fotograf.setArac(arac);

        // Kullanıcının yüklediği orijinal dosya adı
        fotograf.setDosyaAdi(
                dosya.getOriginalFilename()
        );

        // Cloudinary URL
        fotograf.setDosyaYolu(cloudinaryUrl);

        // Cloudinary public ID
        fotograf.setCloudinaryPublicId(
                cloudinaryPublicId
        );

        fotograf.setYuklenmeTarihi(
                LocalDateTime.now()
        );

        return fotografRepository.save(fotograf);
    }

    @Override
    public List<Fotograf> fotograflariGetir(UUID aracPublicId) {

        Arac arac = aracRepository.findByPublicId(aracPublicId)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        return fotografRepository.findByAracId(arac.getId());
    }

    @Override
    public Fotograf fotografGetir(
            UUID aracPublicId,
            Long fotografId
    ) {

        Arac arac = aracRepository.findByPublicId(aracPublicId)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        Fotograf fotograf = fotografRepository.findById(fotografId)
                .orElseThrow(() -> new RuntimeException("Fotoğraf bulunamadı."));

        if (!fotograf.getArac().getId().equals(arac.getId())) {
            throw new RuntimeException(
                    "Fotoğraf bu araca ait değil."
            );
        }

        return fotograf;
    }

    @Override
    public void fotografSil(
            UUID aracPublicId,
            Long fotografId
    ) {

        Arac arac = aracRepository.findByPublicId(aracPublicId)
                .orElseThrow(() -> new RuntimeException("Araç bulunamadı."));

        Fotograf fotograf = fotografRepository.findById(fotografId)
                .orElseThrow(() -> new RuntimeException("Fotoğraf bulunamadı."));

        if (!fotograf.getArac().getId().equals(arac.getId())) {
            throw new RuntimeException(
                    "Fotoğraf bu araca ait değil."
            );
        }

        // ============================================================
        // CLOUDINARY'DEN SİL
        // ============================================================

        try {

            if (fotograf.getCloudinaryPublicId() != null) {

                cloudinary.uploader().destroy(
                        fotograf.getCloudinaryPublicId(),
                        ObjectUtils.asMap(
                                "resource_type", "image"
                        )
                );
            }

        } catch (Exception e) {

            throw new RuntimeException(
                    "Fotoğraf Cloudinary'den silinemedi.",
                    e
            );
        }

        // ============================================================
        // DB'DEN SİL
        // ============================================================

        fotografRepository.delete(fotograf);
    }
}