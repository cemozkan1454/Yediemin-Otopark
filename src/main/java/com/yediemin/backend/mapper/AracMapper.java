package com.yediemin.backend.mapper;

import com.yediemin.backend.dto.AracDetayDto;
import com.yediemin.backend.dto.AracDto;
import com.yediemin.backend.dto.AracListeDto;
import com.yediemin.backend.entity.Arac;

public class AracMapper {

    public static AracDto toDto(Arac arac) {

        AracDto dto = new AracDto();

        dto.setPublicId(arac.getPublicId());
        dto.setPlaka(arac.getPlaka());
        dto.setMarka(arac.getMarka());
        dto.setModel(arac.getModel());
        dto.setRenk(arac.getRenk());
        dto.setAracTuru(arac.getAracTuru());
        dto.setCekildigiBirim(arac.getCekildigiBirim());
        dto.setCekiciFirma(arac.getCekiciFirma());
        dto.setCekiciUcreti(arac.getCekiciUcreti());
        dto.setTutanakNo(arac.getTutanakNo());
        dto.setAnahtarVarMi(arac.getAnahtarVarMi());
        dto.setGirisTarihi(arac.getGirisTarihi());
        dto.setCikisTarihi(arac.getCikisTarihi());
        dto.setSebep(arac.getSebep());
        dto.setAciklama(arac.getAciklama());
        dto.setCekiciyeOdendiMi(arac.getCekiciyeOdendiMi());
        if (arac.getFotograflar() != null
                && !arac.getFotograflar().isEmpty()
                && arac.getPublicId() != null) {

            dto.setKapakFotografi(
                    "/fotograf/dosya/"
                            + arac.getPublicId()
                            + "/"
                            + arac.getFotograflar().get(0).getId()
            );
        }
        return dto;
    }

    public static Arac toEntity(AracDto dto) {

        Arac arac = new Arac();

        arac.setPlaka(dto.getPlaka());
        arac.setMarka(dto.getMarka());
        arac.setModel(dto.getModel());
        arac.setRenk(dto.getRenk());
        arac.setAracTuru(dto.getAracTuru());
        arac.setCekildigiBirim(dto.getCekildigiBirim());
        arac.setCekiciFirma(dto.getCekiciFirma());
        arac.setCekiciUcreti(dto.getCekiciUcreti());
        arac.setTutanakNo(dto.getTutanakNo());
        arac.setAnahtarVarMi(dto.getAnahtarVarMi());
        arac.setGirisTarihi(dto.getGirisTarihi());
        arac.setCikisTarihi(dto.getCikisTarihi());
        arac.setSebep(dto.getSebep());
        arac.setAciklama(dto.getAciklama());
        arac.setCekiciyeOdendiMi(dto.getCekiciyeOdendiMi());

        return arac;
    }

    public static AracListeDto toListeDto(Arac arac) {

        AracListeDto dto = new AracListeDto();

        dto.setId(arac.getId());
        dto.setPublicId(arac.getPublicId());
        dto.setPlaka(arac.getPlaka());
        dto.setMarka(arac.getMarka());

        dto.setModel(arac.getModel());

        if (arac.getAracTuru() != null) {
            dto.setAracTuru(arac.getAracTuru().name());
        }

        if (arac.getDurum() != null) {
            dto.setDurum(arac.getDurum().name());
        }

        if (arac.getFotograflar() != null
                && !arac.getFotograflar().isEmpty()
                && arac.getPublicId() != null) {

            dto.setKapakFotografi(
                    "/fotograf/dosya/"
                            + arac.getPublicId()
                            + "/"
                            + arac.getFotograflar().get(0).getId()
            );
        }
        return dto;
    }

    public static AracDetayDto toDetayDto(Arac arac) {

        AracDetayDto dto = new AracDetayDto();
        dto.setId(arac.getId());
        dto.setPublicId(arac.getPublicId());
        dto.setPlaka(arac.getPlaka());
        dto.setMarka(arac.getMarka());
        dto.setModel(arac.getModel());
        dto.setRenk(arac.getRenk());

        if (arac.getAracTuru() != null) {
            dto.setAracTuru(arac.getAracTuru().name());
        }

        if (arac.getDurum() != null) {
            dto.setDurum(arac.getDurum().name());
        }

        dto.setSebep(arac.getSebep());

        dto.setCekildigiBirim(
                arac.getCekildigiBirim() != null
                        ? arac.getCekildigiBirim().name()
                        : null
        );

        dto.setCekiciFirma(arac.getCekiciFirma());
        dto.setCekiciUcreti(arac.getCekiciUcreti());

        dto.setTutanakNo(arac.getTutanakNo());
        dto.setAnahtarVarMi(arac.getAnahtarVarMi());

        dto.setGirisTarihi(arac.getGirisTarihi());
        dto.setCikisTarihi(arac.getCikisTarihi());

        dto.setOtoparkUcreti(arac.getOtoparkUcreti());
        dto.setToplamUcret(arac.getToplamUcret());
        dto.setAciklama(arac.getAciklama());
        dto.setCekiciyeOdendiMi(arac.getCekiciyeOdendiMi());
        return dto;
    }
}
