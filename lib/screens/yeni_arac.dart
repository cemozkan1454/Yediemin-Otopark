import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/arac_service.dart';

class YeniAracPage extends StatefulWidget {
  const YeniAracPage({super.key});

  @override
  State<YeniAracPage> createState() => _YeniAracPageState();
}

class _YeniAracPageState extends State<YeniAracPage> {
  final _formKey = GlobalKey<FormState>();

  final plakaController = TextEditingController();
  final markaController = TextEditingController();
  final modelController = TextEditingController();
  final renkController = TextEditingController();
  final sebepController = TextEditingController();
  final birimController = TextEditingController();
  final cekiciController = TextEditingController();
  final cekiciUcretiController = TextEditingController();
  final tutanakController = TextEditingController();
  final aciklamaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> fotograflar = [];
  final AracService _aracService = AracService();

  String? aracTuru;
  String? cekildigiBirim;
  bool anahtarVarMi = false;
  bool _kaydediliyor = false;

  @override
  void dispose() {
    plakaController.dispose();
    markaController.dispose();
    modelController.dispose();
    renkController.dispose();
    sebepController.dispose();
    birimController.dispose();
    cekiciController.dispose();
    cekiciUcretiController.dispose();
    tutanakController.dispose();
    aciklamaController.dispose();

    super.dispose();
  }

  // ============================================================
  // ARAÇ KAYDET
  // ============================================================

  Future<void> kaydet() async {
    if (_kaydediliyor) return;

    if (!_formKey.currentState!.validate()) {
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
      'girisTarihi': DateTime.now().toIso8601String(),
      'cikisTarihi': null,
      'sebep': sebepController.text.trim(),
      'aciklama': aciklamaController.text.trim(),
      'cekiciyeOdendiMi': false,
    };

    try {
      final arac = await _aracService.aracKaydet(body);
      final publicId = arac.publicId;

      if (publicId == null || publicId.isEmpty) {
        throw const FormatException('Sunucu araç kimliğini döndürmedi.');
      }

      await Future.wait(
        fotograflar.map(
          (fotograf) => _aracService.fotografYukle(
            aracPublicId: publicId,
            dosyaYolu: fotograf.path,
          ),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Araç başarıyla kaydedildi'
            '${fotograflar.isEmpty ? '' : ' ve fotoğrafları yüklendi'}',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _kaydediliyor = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kayıt tamamlanamadı: $e')));
    }
  }

  // ============================================================
  // FOTOĞRAF KAYNAĞI
  // ============================================================

  Future<void> fotografKaynakSec() async {
    if (fotograflar.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En fazla 8 fotoğraf ekleyebilirsiniz.')),
      );
      return;
    }

    final kaynak = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Fotoğrafın kaynağını seçin.'),
                const SizedBox(height: 12),

                // KAMERA
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt_outlined),
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
                    child: Icon(Icons.photo_library_outlined),
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
      final kalanLimit = 8 - fotograflar.length;

      final secilenFotograflar = await _picker.pickMultiImage(
        imageQuality: 75,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted || secilenFotograflar.isEmpty) return;

      final eklenecekler = secilenFotograflar.take(kalanLimit).toList();

      setState(() {
        fotograflar.addAll(eklenecekler);
      });

      // Kullanıcı 8'den fazla seçtiyse bilgi ver
      if (secilenFotograflar.length > kalanLimit && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'En fazla 8 fotoğraf eklenebilir. '
              '${eklenecekler.length} fotoğraf eklendi.',
            ),
          ),
        );
      }

      return;
    }

    // ============================================================
    // KAMERA → TEK FOTOĞRAF
    // ============================================================

    final XFile? fotograf = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (fotograf != null && mounted) {
      setState(() {
        fotograflar.add(fotograf);
      });
    }
  }

  // ============================================================
  // BÖLÜM KARTI
  // ============================================================

  Widget _sectionCard({required String title, required Widget child}) {
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8A9BB3),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // INPUT TASARIMI
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
        gradient: LinearGradient(
          colors: _kaydediliyor
              ? [Colors.grey.shade400, Colors.grey.shade500]
              : const [Color(0xFF102B50), Color(0xFF285F9E)],
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
          onTap: _kaydediliyor ? null : kaydet,
          child: Center(
            child: _kaydediliyor
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Fotoğraflar yükleniyor...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Aracı Kaydet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
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
          'Yeni Araç Ekle',
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
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF102B50),
                  borderRadius: BorderRadius.circular(11),
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
            // ARAÇ KİMLİĞİ
            // ==================================================
            _sectionCard(
              title: 'ARAÇ KİMLİĞİ',
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
                          decoration: _inputDecoration(label: 'Araç Türü'),
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
                            if (aracTuru == null || aracTuru!.isEmpty) {
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
                      hint: 'Park ihlali, Kırmızı ışık...',
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
                      if (cekildigiBirim == null || cekildigiBirim!.isEmpty) {
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
              title: 'ARAÇ FOTOĞRAFLARI (${fotograflar.length}/8)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aracın mevcut durumunu kayıt altına alın.',
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
                          onTap: fotograflar.length >= 8
                              ? null
                              : fotografKaynakSec,
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
                                  Icons.camera_alt_outlined,
                                  color: const Color(0xFF8AA0BC),
                                  size: 22,
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  fotograflar.length >= 8 ? 'Limit' : 'Ekle',
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

                        // FOTOĞRAFLAR
                        ...fotograflar.map(
                          (fotograf) => Container(
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
                                            fotograflar.remove(fotograf);
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ANA KAYDET BUTONU
            // ==================================================
            _kaydetButonu(),

            const SizedBox(height: 10),

            Center(
              child: Text(
                'Araç kaydı oluşturulduktan sonra fotoğraflar yüklenecektir.',
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
