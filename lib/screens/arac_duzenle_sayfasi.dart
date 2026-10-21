import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/arac.dart';
import '../services/arac_service.dart';

class AracDuzenleSayfasi extends StatefulWidget {
  const AracDuzenleSayfasi({super.key, required this.arac});

  final Arac arac;

  @override
  State<AracDuzenleSayfasi> createState() => _AracDuzenleSayfasiState();
}

class _AracDuzenleSayfasiState extends State<AracDuzenleSayfasi> {
  final _formKey = GlobalKey<FormState>();

  final AracService _aracService = AracService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController plakaController;
  late final TextEditingController markaController;
  late final TextEditingController modelController;
  late final TextEditingController renkController;
  late final TextEditingController sebepController;
  late final TextEditingController cekiciController;
  late final TextEditingController cekiciUcretiController;
  late final TextEditingController tutanakController;
  late final TextEditingController aciklamaController;

  String? aracTuru;
  String? cekildigiBirim;

  bool anahtarVarMi = false;
  bool cekiciyeOdendiMi = false;
  bool _kaydediliyor = false;

  final List<XFile> yeniFotograflar = [];

  @override
  void initState() {
    super.initState();

    final arac = widget.arac;

    plakaController = TextEditingController(text: arac.plaka);

    markaController = TextEditingController(text: arac.marka ?? '');

    modelController = TextEditingController(text: arac.model ?? '');

    renkController = TextEditingController(text: arac.renk ?? '');

    sebepController = TextEditingController(text: arac.sebep ?? '');

    cekiciController = TextEditingController(text: arac.cekiciFirma ?? '');

    cekiciUcretiController = TextEditingController(
      text: arac.cekiciUcreti?.toString() ?? '',
    );

    tutanakController = TextEditingController(text: arac.tutanakNo ?? '');

    aciklamaController = TextEditingController(text: arac.aciklama ?? '');

    aracTuru = arac.aracTuru;
    cekildigiBirim = arac.cekildigiBirim;

    anahtarVarMi = arac.anahtarVarMi ?? false;
    cekiciyeOdendiMi = arac.cekiciyeOdendiMi ?? false;
  }

  @override
  void dispose() {
    plakaController.dispose();
    markaController.dispose();
    modelController.dispose();
    renkController.dispose();
    sebepController.dispose();
    cekiciController.dispose();
    cekiciUcretiController.dispose();
    tutanakController.dispose();
    aciklamaController.dispose();

    super.dispose();
  }

  // ============================================================
  // ARAÇ GÜNCELLE
  // ============================================================

  Future<void> _kaydet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final id = widget.arac.id;
    final publicId = widget.arac.publicId;

    if (id == null) {
      _mesajGoster('Araç ID bilgisi bulunamadı.');
      return;
    }

    if (publicId == null || publicId.isEmpty) {
      _mesajGoster('Araç public ID bilgisi bulunamadı.');
      return;
    }

    setState(() {
      _kaydediliyor = true;
    });

    final body = {
      'plaka': plakaController.text.trim(),
      'marka': markaController.text.trim(),
      'model': modelController.text.trim(),
      'renk': renkController.text.trim(),
      'aracTuru': aracTuru,
      'cekildigiBirim': cekildigiBirim,
      'cekiciFirma': cekiciController.text.trim(),
      'cekiciUcreti': double.tryParse(
        cekiciUcretiController.text.replaceAll(',', '.'),
      ),
      'tutanakNo': tutanakController.text.trim(),
      'anahtarVarMi': anahtarVarMi,
      'sebep': sebepController.text.trim(),
      'aciklama': aciklamaController.text.trim(),
      'cekiciyeOdendiMi': cekiciyeOdendiMi,
    };

    try {
      await _aracService.aracGuncelle(id: id, body: body);

      for (final fotograf in yeniFotograflar) {
        await _aracService.fotografYukle(
          aracPublicId: publicId,
          dosyaYolu: fotograf.path,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            yeniFotograflar.isEmpty
                ? 'Araç bilgileri güncellendi.'
                : 'Araç bilgileri ve fotoğraflar güncellendi.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      _mesajGoster('Güncelleme başarısız:\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _kaydediliyor = false;
        });
      }
    }
  }

  // ============================================================
  // MESAJ
  // ============================================================

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  // ============================================================
  // FOTOĞRAF
  // ============================================================

  Future<void> _fotografKaynakSec() async {
    final mevcutFotografSayisi =
        widget.arac.fotograflar.length + yeniFotograflar.length;

    if (mevcutFotografSayisi >= 8) {
      _mesajGoster('En fazla 8 fotoğraf olabilir.');
      return;
    }

    final kaynak = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fotoğraf ekle',
                  style: TextStyle(
                    color: Color(0xFF0D1B2A),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fotoğrafın kaynağını seçin.',
                  style: TextStyle(color: Color(0xFF7C91AB)),
                ),
                const SizedBox(height: 12),

                // KAMERA
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF0F8),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF285F9E),
                    ),
                  ),
                  title: const Text('Kamera'),
                  subtitle: const Text('Yeni fotoğraf çek'),
                  onTap: () {
                    Navigator.pop(sheetContext, ImageSource.camera);
                  },
                ),

                // GALERİ
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF0F8),
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF285F9E),
                    ),
                  ),
                  title: const Text('Galeri'),
                  subtitle: const Text('Birden fazla fotoğraf seç'),
                  onTap: () {
                    Navigator.pop(sheetContext, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (kaynak == null || !mounted) return;

    // ============================================================
    // GALERİ → ÇOKLU FOTOĞRAF
    // ============================================================

    if (kaynak == ImageSource.gallery) {
      final kalanLimit =
          8 - widget.arac.fotograflar.length - yeniFotograflar.length;

      final secilenFotograflar = await _picker.pickMultiImage(imageQuality: 85);

      if (!mounted || secilenFotograflar.isEmpty) return;

      final eklenecekler = secilenFotograflar.take(kalanLimit).toList();

      setState(() {
        yeniFotograflar.addAll(eklenecekler);
      });

      if (secilenFotograflar.length > kalanLimit && mounted) {
        _mesajGoster(
          'En fazla 8 fotoğraf olabilir. '
          '${eklenecekler.length} fotoğraf eklendi.',
        );
      }

      return;
    }

    // ============================================================
    // KAMERA → TEK FOTOĞRAF
    // ============================================================

    final fotograf = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (fotograf != null && mounted) {
      setState(() {
        yeniFotograflar.add(fotograf);
      });
    }
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: const Color(0xFF285F9E)),
                const SizedBox(width: 7),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF8A9BB3),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration _inputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Color(0xFF17345D),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: Color(0xFF91A0B3), fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE4EF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE4EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF285B97), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // ============================================================
  // KAYDET BUTONU
  // ============================================================

  Widget _kaydetButonu() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF102B50), Color(0xFF285F9E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16365F).withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _kaydediliyor ? null : _kaydet,
          child: Center(
            child: _kaydediliyor
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 9),
                      Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mevcutFotografSayisi = widget.arac.fotograflar.length;

    final toplamFotografSayisi = mevcutFotografSayisi + yeniFotograflar.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0D1B2A),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Araç Düzenle',
          style: TextStyle(
            color: Color(0xFF0D1B2A),
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0F8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Color(0xFF285F9E),
                ),
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // FORM
      // ========================================================
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            // ==================================================
            // DÜZENLEME BİLGİSİ
            // ==================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF102B50), Color(0xFF285F9E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Araç kaydını düzenliyorsunuz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          plakaController.text.isEmpty
                              ? 'Araç bilgilerini güncelleyin.'
                              : '${plakaController.text} kayıt bilgileri',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // ARAÇ KİMLİĞİ
            // ==================================================
            _sectionCard(
              title: 'ARAÇ KİMLİĞİ',
              icon: Icons.directions_car_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: plakaController,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: Color(0xFF60758F),
                    ),
                    decoration: _inputDecoration(
                      label: 'Plaka *',
                      hint: '34 ABC 123',
                    ),
                    onChanged: (value) {
                      final buyukHarf = value.toUpperCase();

                      if (value != buyukHarf) {
                        plakaController.value = plakaController.value.copyWith(
                          text: buyukHarf,
                          selection: TextSelection.collapsed(
                            offset: buyukHarf.length,
                          ),
                        );
                      }

                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Plaka giriniz';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: markaController,
                          decoration: _inputDecoration(
                            label: 'Marka *',
                            hint: 'BMW',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: modelController,
                          decoration: _inputDecoration(
                            label: 'Model *',
                            hint: '3 Serisi',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // ARAÇ DETAYLARI
            // ==================================================
            _sectionCard(
              title: 'ARAÇ DETAYLARI',
              icon: Icons.car_repair_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: renkController,
                          decoration: _inputDecoration(
                            label: 'Renk',
                            hint: 'Beyaz',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: aracTuru,
                          isExpanded: true,
                          decoration: _inputDecoration(label: 'Araç Türü *'),
                          items: const [
                            DropdownMenuItem(
                              value: 'OTOMOBIL',
                              child: Text('Otomobil'),
                            ),
                            DropdownMenuItem(
                              value: 'MOTOSIKLET',
                              child: Text('Motosiklet'),
                            ),
                            DropdownMenuItem(
                              value: 'KAMYONET',
                              child: Text('Kamyonet'),
                            ),
                            DropdownMenuItem(value: 'TIR', child: Text('Tır')),
                            DropdownMenuItem(
                              value: 'ELEKTRIKLI_BISIKLET',
                              child: Text('Elektrikli Bisiklet'),
                            ),
                            DropdownMenuItem(
                              value: 'TRAKTOR',
                              child: Text('Traktör'),
                            ),
                            DropdownMenuItem(
                              value: 'ROMORK',
                              child: Text('Römork'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              aracTuru = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Seçiniz';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: sebepController,
                    decoration: _inputDecoration(
                      label: 'Giriş Sebebi',
                      hint: 'Park ihlali, kırmızı ışık...',
                    ),
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: cekildigiBirim,
                    isExpanded: true,
                    decoration: _inputDecoration(label: 'Çekildiği Birim *'),
                    items: const [
                      DropdownMenuItem(value: 'TRAFIK', child: Text('Trafik')),
                      DropdownMenuItem(value: 'POLIS', child: Text('Polis')),
                      DropdownMenuItem(
                        value: 'JANDARMA',
                        child: Text('Jandarma'),
                      ),
                      DropdownMenuItem(value: 'ZABITA', child: Text('Zabıta')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        cekildigiBirim = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seçiniz';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // ÇEKİCİ BİLGİLERİ
            // ==================================================
            _sectionCard(
              title: 'ÇEKİCİ BİLGİLERİ',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  TextFormField(
                    controller: cekiciController,
                    decoration: _inputDecoration(
                      label: 'Çekici Firma *',
                      hint: 'Yıldız Çekici',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Çekici firma giriniz';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cekiciUcretiController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: 'Çekici Ücreti *',
                            hint: '850',
                          ).copyWith(suffixText: '₺'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ücret giriniz';
                            }

                            final ucret = double.tryParse(
                              value.replaceAll(',', '.'),
                            );

                            if (ucret == null) {
                              return 'Geçersiz';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: tutanakController,
                          decoration: _inputDecoration(
                            label: 'Tutanak No',
                            hint: 'TRF-2024-...',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // DİĞER
            // ==================================================
            _sectionCard(
              title: 'DİĞER',
              icon: Icons.tune_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Anahtar Mevcut',
                              style: TextStyle(
                                color: Color(0xFF17345D),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Araç anahtarı teslim alındı mı?',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: anahtarVarMi,
                        activeColor: const Color(0xFF285F9E),
                        onChanged: (value) {
                          setState(() {
                            anahtarVarMi = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const Divider(height: 24, color: Color(0xFFE8EDF3)),

                  TextFormField(
                    controller: aciklamaController,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      label: 'Açıklama',
                      hint: 'Araçla ilgili notlar...',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // FOTOĞRAFLAR
            // ==================================================
            _sectionCard(
              title: 'ARAÇ FOTOĞRAFLARI ($toplamFotografSayisi/8)',
              icon: Icons.photo_library_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mevcut fotoğrafları görüntüleyin veya yeni fotoğraf ekleyin.',
                    style: TextStyle(color: Color(0xFF8A9BB3), fontSize: 12),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 86,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // FOTOĞRAF EKLE
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: toplamFotografSayisi >= 8
                              ? null
                              : _fotografKaynakSec,
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFC9D6E6),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  color: toplamFotografSayisi >= 8
                                      ? const Color(0xFFB8C4D1)
                                      : const Color(0xFF8AA0BC),
                                  size: 22,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  toplamFotografSayisi >= 8 ? 'Limit' : 'Ekle',
                                  style: const TextStyle(
                                    color: Color(0xFF7C91AB),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // MEVCUT FOTOĞRAFLAR
                        ...widget.arac.fotograflar.map((fotograf) {
                          return Container(
                            width: 82,
                            height: 82,
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    fotograf.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFF0F3F7),
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                          color: Color(0xFF9AAABC),
                                        ),
                                      );
                                    },
                                  ),

                                  Positioned(
                                    left: 5,
                                    top: 5,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.55,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Mevcut',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // YENİ FOTOĞRAFLAR
                        ...yeniFotograflar.map((fotograf) {
                          return Container(
                            width: 82,
                            height: 82,
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(fotograf.path),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: Colors.black.withValues(
                                        alpha: 0.55,
                                      ),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          setState(() {
                                            yeniFotograflar.remove(fotograf);
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // KAYDET
            // ==================================================
            _kaydetButonu(),

            const SizedBox(height: 10),

            Center(
              child: Text(
                'Değişiklikler kaydedildiğinde araç detayları güncellenecektir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
