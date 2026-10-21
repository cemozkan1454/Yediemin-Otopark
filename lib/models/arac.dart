class AracFotograf {
  const AracFotograf({required this.id, required this.url});

  final int id;
  final String url;

  factory AracFotograf.fromJson(Map<String, dynamic> json) {
    return AracFotograf(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['dosyaYolu']?.toString() ?? json['url']?.toString() ?? '',
    );
  }
}

class Arac {
  const Arac({
    required this.plaka,
    this.publicId,
    this.id,
    this.marka,
    this.model,
    this.renk,
    this.aracTuru,
    this.durum,
    this.cekildigiBirim,
    this.cekiciFirma,
    this.cekiciUcreti,
    this.cekiciyeOdendiMi,
    this.tutanakNo,
    this.anahtarVarMi,
    this.girisTarihi,
    this.cikisTarihi,
    this.otoparkUcreti,
    this.toplamUcret,
    this.sebep,
    this.aciklama,
    this.kapakFotografi,
    this.fotograflar = const [],
  });

  final String? publicId;
  final int? id;
  final String plaka;
  final String? marka;
  final String? model;
  final String? renk;
  final String? aracTuru;
  final String? durum;
  final String? cekildigiBirim;
  final String? cekiciFirma;
  final num? cekiciUcreti;
  final bool? cekiciyeOdendiMi;
  final String? tutanakNo;
  final bool? anahtarVarMi;
  final DateTime? girisTarihi;
  final DateTime? cikisTarihi;
  final num? otoparkUcreti;
  final num? toplamUcret;
  final String? sebep;
  final String? aciklama;
  final String? kapakFotografi;
  final List<AracFotograf> fotograflar;

  bool get iceride => durum == null ? cikisTarihi == null : durum == 'ICERIDE';

  String get markaModel {
    final degerler = [
      marka,
      model,
    ].whereType<String>().where((deger) => deger.trim().isNotEmpty);

    return degerler.isEmpty ? 'Marka/model girilmemiş' : degerler.join(' ');
  }

  factory Arac.fromJson(Map<String, dynamic> json) {
    DateTime? tarihiDonustur(dynamic deger) =>
        deger is String && deger.isNotEmpty ? DateTime.tryParse(deger) : null;

    bool? boolaDonustur(dynamic deger) => deger is bool
        ? deger
        : deger is String
        ? deger.toLowerCase() == 'true'
        : null;

    final fotografJson = json['fotograflar'];

    return Arac(
      publicId: json['publicId']?.toString(),
      id: (json['id'] as num?)?.toInt(),
      plaka: json['plaka']?.toString() ?? '-',
      marka: json['marka']?.toString(),
      model: json['model']?.toString(),
      renk: json['renk']?.toString(),
      aracTuru: json['aracTuru']?.toString(),
      durum: json['durum']?.toString(),
      cekildigiBirim: json['cekildigiBirim']?.toString(),
      cekiciFirma: json['cekiciFirma']?.toString(),
      cekiciUcreti: json['cekiciUcreti'] as num?,
      cekiciyeOdendiMi: boolaDonustur(json['cekiciyeOdendiMi']),
      tutanakNo: json['tutanakNo']?.toString(),
      anahtarVarMi: boolaDonustur(json['anahtarVarMi']),
      girisTarihi: tarihiDonustur(json['girisTarihi']),
      cikisTarihi: tarihiDonustur(json['cikisTarihi']),
      otoparkUcreti: json['otoparkUcreti'] as num?,
      toplamUcret: json['toplamUcret'] as num?,
      sebep: json['sebep']?.toString(),
      aciklama: json['aciklama']?.toString(),
      kapakFotografi: json['kapakFotografi']?.toString(),
      fotograflar: fotografJson is List
          ? fotografJson
                .whereType<Map>()
                .map(
                  (foto) =>
                      AracFotograf.fromJson(Map<String, dynamic>.from(foto)),
                )
                .toList()
          : const [],
    );
  }
}
