import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/arac.dart';
import '../models/arac_sayfa.dart' as sayfa_model;

class AracService {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://yediemin-backend.onrender.com',
  );

  // ============================================================
  // DASHBOARD ÖZET
  // ============================================================

  Future<Map<String, dynamic>> dashboardOzetiGetir() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/ozet'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Dashboard özeti alınamadı: '
      '${response.statusCode} ${response.body}',
    );
  }

  // ============================================================
  // TÜM ARAÇLAR - PAGINATION
  // ============================================================

  Future<sayfa_model.AracSayfa> araclariGetir({
    required int sayfa,
    required int boyut,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/arac/liste/sayfali?sayfa=$sayfa&boyut=$boyut'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return sayfa_model.AracSayfa.fromJson(data);
    }

    throw Exception(
      'Araçlar alınamadı: '
      '${response.statusCode} ${response.body}',
    );
  }

  // ============================================================
  // İÇERİDEKİ ARAÇLAR - PAGINATION
  // ============================================================

  Future<sayfa_model.AracSayfa> iceridekiAraclariGetir({
    required int sayfa,
    required int boyut,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/arac/iceride/sayfali?sayfa=$sayfa&boyut=$boyut'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return sayfa_model.AracSayfa.fromJson(data);
    }

    throw Exception(
      'İçerideki araçlar alınamadı: '
      '${response.statusCode} ${response.body}',
    );
  }

  // ============================================================
  // ÇIKAN ARAÇLAR - PAGINATION
  // ============================================================

  Future<sayfa_model.AracSayfa> cikanAraclariGetir({
    required int sayfa,
    required int boyut,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/arac/cikti/sayfali?sayfa=$sayfa&boyut=$boyut'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return sayfa_model.AracSayfa.fromJson(data);
    }

    throw Exception(
      'Çıkan araçlar alınamadı: '
      '${response.statusCode} ${response.body}',
    );
  }

  // ============================================================
  // ARAÇ DETAYI
  // ============================================================

  Future<Arac> aracDetayiGetir(String publicId) async {
    final response = await http.get(Uri.parse('$baseUrl/arac/detay/$publicId'));

    if (response.statusCode == 200) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Araç detayı getirilemedi: ${response.body}');
  }

  // ============================================================
  // ÇIKIŞ ÜCRETİ HESAPLA
  // ============================================================

  Future<Arac> cikisUcretiHesapla(String publicId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/arac/$publicId/cikis-ucreti'),
    );

    if (response.statusCode == 200) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Çıkış ücreti hesaplanamadı: ${response.body}');
  }

  // ============================================================
  // ARAÇ ÇIKIŞI
  // ============================================================

  Future<Arac> aracCikisiYap(int id, DateTime cikisTarihi) async {
    final response = await http.put(
      Uri.parse('$baseUrl/arac/$id/cikis'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cikisTarihi': cikisTarihi.toIso8601String()}),
    );

    if (response.statusCode == 200) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Araç çıkışı yapılamadı: ${response.body}');
  }

  // ============================================================
  // ARAÇ KAYDET
  // ============================================================

  Future<Arac> aracKaydet(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/arac'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Araç kaydedilemedi: ${response.body}');
  }

  // ============================================================
  // ÇIKIŞI GERİ AL
  // ============================================================

  Future<void> cikisiGeriAl(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/arac/$id/cikis-geri-al'),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception('Çıkış geri alınamadı: ${response.body}');
  }

  // ============================================================
  // FOTOĞRAF YÜKLE
  // ============================================================

  Future<void> fotografYukle({
    required String aracPublicId,
    required String dosyaYolu,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/fotograf/yukle/$aracPublicId'),
    );

    request.files.add(await http.MultipartFile.fromPath('dosya', dosyaYolu));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Fotoğraf yüklenemedi: ${response.statusCode} - $responseBody',
      );
    }
  }

  // ============================================================
  // FOTOĞRAF URL
  // ============================================================

  String fotografUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return '$baseUrl$url';
  }

  // ============================================================
  // FOTOĞRAF SİL
  // ============================================================

  Future<void> fotografSil({
    required String aracPublicId,
    required int fotografId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/fotograf/arac/$aracPublicId/$fotografId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Fotoğraf silinemedi: ${response.body}');
    }
  }

  // ============================================================
  // ARAÇ GÜNCELLE
  // ============================================================

  Future<Arac> aracGuncelle({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/arac/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Araç güncellenemedi: ${response.body}');
  }
  // ============================================================
  // ARAÇ SİL
  // ============================================================

  Future<void> aracSil(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/arac/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Araç silinemedi: ${response.statusCode} ${response.body}',
      );
    }
  }
  // ============================================================
  // ÇEKİCİ ÖDEME
  // ============================================================

  Future<void> cekiciOdemesiGuncelle({
    required int id,
    required bool cekiciyeOdendiMi,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/arac/$id/cekici-odeme'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'cekiciyeOdendiMi': cekiciyeOdendiMi}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Çekici ödeme durumu güncellenemedi: '
        '${response.body}',
      );
    }
  }
  // ============================================================
  // TARİFELERİ GETİR
  // ============================================================

  Future<List<Map<String, dynamic>>> tarifeleriGetir() async {
    final response = await http.get(Uri.parse('$baseUrl/tarife'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;

      return data.map((e) => e as Map<String, dynamic>).toList();
    }

    throw Exception(
      'Tarifeler alınamadı: '
      '${response.statusCode} ${response.body}',
    );
  }

  // ============================================================
  // TARİFE GÜNCELLE
  // ============================================================

  Future<Map<String, dynamic>> tarifeGuncelle({
    required int id,
    required String aracTuru,
    required double gunlukUcret,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tarife/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'aracTuru': aracTuru, 'gunlukUcret': gunlukUcret}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Tarife güncellenemedi: '
      '${response.statusCode} ${response.body}',
    );
  }
  // ============================================================
  // PLAKA İLE ARAÇ ARA
  // ============================================================

  Future<Arac> plakaIleGetir(String plaka) async {
    final temizPlaka = plaka.trim();

    if (temizPlaka.isEmpty) {
      throw Exception('Plaka boş olamaz.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/arac/plaka/${Uri.encodeComponent(temizPlaka)}'),
    );

    if (response.statusCode == 200) {
      return Arac.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    if (response.statusCode == 404) {
      throw Exception('Bu plakaya ait araç bulunamadı.');
    }

    throw Exception('Araç aranamadı: ${response.statusCode} ${response.body}');
  }
  // ============================================================
  // PLAKA ARAMA - PAGINATION
  // ============================================================

  Future<sayfa_model.AracSayfa> plakaIleAra({
    required String plaka,
    required int sayfa,
    required int boyut,
  }) async {
    final temizPlaka = plaka.trim();

    if (temizPlaka.isEmpty) {
      throw Exception('Plaka boş olamaz.');
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/arac/ara'
        '?plaka=${Uri.encodeComponent(temizPlaka)}'
        '&page=$sayfa'
        '&size=$boyut',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return sayfa_model.AracSayfa.fromJson(data);
    }

    throw Exception(
      'Plaka ile arama yapılamadı: '
      '${response.statusCode} ${response.body}',
    );
  }
}
