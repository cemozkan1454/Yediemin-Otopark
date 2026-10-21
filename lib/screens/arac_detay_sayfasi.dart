import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'arac_cikis_sayfasi.dart';
import 'arac_duzenle_sayfasi.dart';
import '../models/arac.dart';
import '../services/arac_service.dart';

class AracDetaySayfasi extends StatefulWidget {
  const AracDetaySayfasi({super.key, required this.arac});

  final Arac arac;

  @override
  State<AracDetaySayfasi> createState() => _AracDetaySayfasiState();
}

class _AracDetaySayfasiState extends State<AracDetaySayfasi> {
  final AracService _aracService = AracService();

  Future<Arac>? _detay;

  @override
  void initState() {
    super.initState();

    final publicId = widget.arac.publicId;

    if (publicId != null && publicId.isNotEmpty) {
      _detay = _aracService.aracDetayiGetir(publicId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Araç Detayı',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final publicId = widget.arac.publicId;

              if (publicId == null || publicId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Araç public ID bilgisi bulunamadı.'),
                  ),
                );
                return;
              }

              try {
                final tamArac = await _aracService.aracDetayiGetir(publicId);

                if (!mounted) return;

                final guncellendi = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AracDuzenleSayfasi(arac: tamArac),
                  ),
                );

                if (guncellendi == true && mounted) {
                  await _detayiYenile();
                }
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Araç bilgileri alınamadı: $e')),
                );
              }
            },
          ),
        ],
      ),

      body: _detay == null
          ? const Center(child: Text('Araç detay kimliği bulunamadı.'))
          : FutureBuilder<Arac>(
              future: _detay,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Araç detayı yüklenemedi:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('Araç detayı bulunamadı.'));
                }

                return _DetayIcerigi(
                  arac: snapshot.data!,
                  onYenile: _detayiYenile,
                );
              },
            ),
    );
  }

  Future<void> _detayiYenile() async {
    final publicId = widget.arac.publicId;

    if (publicId == null || publicId.isEmpty) {
      return;
    }

    final yeniDetay = _aracService.aracDetayiGetir(publicId);

    setState(() {
      _detay = yeniDetay;
    });

    await yeniDetay;
  }
}

// ================================================================
// DETAY İÇERİĞİ
// ================================================================

class _DetayIcerigi extends StatelessWidget {
  const _DetayIcerigi({required this.arac, required this.onYenile});

  final Arac arac;
  final Future<void> Function() onYenile;

  // ============================================================
  // ARAÇ SİL
  // ============================================================

  Future<void> _araciSil(BuildContext context, Arac arac) async {
    if (arac.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç ID bilgisi bulunamadı.')),
      );
      return;
    }

    final onay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Aracı Sil?'),
          content: Text(
            '${arac.plaka} plakalı araç ve bu araca ait tüm '
            'fotoğraflar kalıcı olarak silinecek.\n\n'
            'Bu işlem geri alınamaz.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Aracı Sil'),
            ),
          ],
        );
      },
    );

    if (onay != true) return;

    try {
      await AracService().aracSil(arac.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Araç başarıyla silindi.')));

      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Araç silinemedi: $e')));
    }
  }

  // ============================================================
  // ÇIKIŞI GERİ AL
  // ============================================================

  Future<void> _cikisiGeriAl(BuildContext context, Arac arac) async {
    if (arac.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç ID bilgisi bulunamadı.')),
      );
      return;
    }

    final onay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Çıkışı geri al?'),
          content: const Text(
            'Bu aracın çıkış işlemi geri alınacak '
            've araç tekrar içeride olarak işaretlenecek.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Geri Al'),
            ),
          ],
        );
      },
    );

    if (onay != true) return;

    try {
      await AracService().cikisiGeriAl(arac.id!);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış işlemi geri alındı.')),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Çıkış geri alınamadı: $e')));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final lacivert = const Color(0xFF0D1B2A);
    final mavi = const Color(0xFF24558C);

    final durumRengi = arac.iceride ? Colors.green : Colors.grey;

    return RefreshIndicator(
      onRefresh: onYenile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ======================================================
          // ÜST ARAÇ KARTI
          // ======================================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lacivert, mavi],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            arac.plaka,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            arac.markaModel,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _DurumRozeti(
                      iceride: arac.iceride,
                      renk: durumRengi,
                      darkBackground: true,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Etiket(
                      icon: Icons.directions_car_outlined,
                      text: _duzenle(arac.aracTuru),
                    ),

                    _Etiket(
                      icon: Icons.palette_outlined,
                      text: _duzenle(arac.renk),
                    ),

                    _Etiket(
                      icon: arac.anahtarVarMi == true
                          ? Icons.key
                          : Icons.key_off,
                      text: arac.anahtarVarMi == true
                          ? 'Anahtar mevcut'
                          : 'Anahtar yok',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ======================================================
          // FOTOĞRAFLAR
          // ======================================================
          const _Baslik('Araç Fotoğrafları'),

          _FotoGaleri(
            fotograflar: arac.fotograflar,
            aracPublicId: arac.publicId ?? '',
          ),

          const SizedBox(height: 24),

          // ======================================================
          // ARAÇ BİLGİLERİ
          // ======================================================
          const _Baslik('Araç Bilgileri'),

          _BilgiKart(
            children: [
              _BilgiSatiri('Araç türü', _duzenle(arac.aracTuru)),

              _BilgiSatiri('Renk', _duzenle(arac.renk)),

              _BilgiSatiri('Giriş tarihi', _tarih(arac.girisTarihi)),

              _BilgiSatiri('Çıkış tarihi', _tarih(arac.cikisTarihi)),

              _BilgiSatiri(
                'Anahtar',
                arac.anahtarVarMi == null
                    ? '-'
                    : arac.anahtarVarMi!
                    ? 'Mevcut'
                    : 'Mevcut değil',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // ÇEKİCİ VE TUTANAK
          // ======================================================
          const _Baslik('Çekici ve Tutanak'),

          _BilgiKart(
            children: [
              _BilgiSatiri('Çekildiği birim', _duzenle(arac.cekildigiBirim)),

              _BilgiSatiri('Çekici firma', _duzenle(arac.cekiciFirma)),

              _BilgiSatiri('Çekici ücreti', _para(arac.cekiciUcreti)),

              _BilgiSatiri(
                'Çekici ödemesi',
                arac.cekiciyeOdendiMi == true ? 'Ödendi' : 'Ödenmedi',
              ),

              const SizedBox(height: 8),

              // ==================================================
              // ÇEKİCİ ÖDEME BUTONU
              // ==================================================
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (arac.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Araç ID bilgisi bulunamadı.'),
                        ),
                      );
                      return;
                    }

                    final yeniDurum = !(arac.cekiciyeOdendiMi ?? false);

                    // ==================================================
                    // ARAÇ İÇERİDEYSE EKSTRA ONAY
                    // ==================================================
                    if (arac.iceride) {
                      final onay = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          final mevcutDurum = arac.cekiciyeOdendiMi == true;

                          return AlertDialog(
                            title: const Text('Ödeme durumunu değiştir?'),
                            content: Text(
                              mevcutDurum
                                  ? 'Çekici ücreti "Ödendi" olarak işaretlenmiş.\n\n'
                                        'Bu durumu "Ödenmedi" olarak değiştirmek istediğinize emin misiniz?'
                                  : 'Çekici ücreti henüz ödenmemiş olarak görünüyor.\n\n'
                                        'Bu durumu "Ödendi" olarak değiştirmek istediğinize emin misiniz?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Vazgeç'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text('Değiştir'),
                              ),
                            ],
                          );
                        },
                      );

                      // Onay verilmediyse hiçbir şey yapma
                      if (onay != true) {
                        return;
                      }
                    }

                    // ==================================================
                    // GÜNCELLE
                    // ==================================================
                    try {
                      await AracService().cekiciOdemesiGuncelle(
                        id: arac.id!,
                        cekiciyeOdendiMi: yeniDurum,
                      );

                      if (!context.mounted) {
                        return;
                      }

                      await onYenile();

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            yeniDurum
                                ? 'Çekici ücreti ödendi olarak işaretlendi.'
                                : 'Çekici ücreti ödenmedi olarak işaretlendi.',
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ödeme durumu güncellenemedi: $e'),
                        ),
                      );
                    }
                  },

                  icon: Icon(
                    arac.cekiciyeOdendiMi == true
                        ? Icons.undo
                        : Icons.check_circle_outline,
                  ),

                  label: Text(
                    arac.cekiciyeOdendiMi == true
                        ? 'Ödenmedi Olarak İşaretle'
                        : 'Ödendi Olarak İşaretle',
                  ),

                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: BorderSide(
                      color: arac.cekiciyeOdendiMi == true
                          ? Colors.green
                          : mavi,
                    ),
                    foregroundColor: arac.cekiciyeOdendiMi == true
                        ? Colors.green.shade700
                        : mavi,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              _BilgiSatiri('Tutanak no', _duzenle(arac.tutanakNo)),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // AÇIKLAMALAR
          // ======================================================
          const _Baslik('Açıklamalar'),

          _BilgiKart(
            children: [
              _BilgiSatiri('Giriş sebebi', _duzenle(arac.sebep)),

              _BilgiSatiri(
                'Açıklama',
                _duzenle(arac.aciklama),
                cokSatirli: true,
              ),
            ],
          ),

          // ======================================================
          // ÇIKIŞ İŞLEMİ
          // ======================================================
          if (arac.iceride) ...[
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  final publicId = arac.publicId;

                  if (publicId == null || publicId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Araç kimliği bulunamadı.')),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final hesaplananArac = await AracService()
                        .cikisUcretiHesapla(publicId);

                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AracCikisSayfasi(arac: hesaplananArac),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ücret hesaplanamadı: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text(
                  'Çıkış İşlemi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  backgroundColor: mavi,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          // ======================================================
          // ÇIKIŞI GERİ AL
          // ======================================================
          if (!arac.iceride) ...[
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cikisiGeriAl(context, arac),
                icon: const Icon(Icons.undo),
                label: const Text('Çıkışı Geri Al'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],

          // ======================================================
          // SİL
          // ======================================================
          const SizedBox(height: 28),

          const Divider(),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _araciSil(context, arac),
              icon: const Icon(Icons.delete_outline),
              label: const Text(
                'Aracı Sil',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // YARDIMCI METOTLAR
  // ============================================================

  static String _duzenle(String? deger) {
    if (deger == null || deger.trim().isEmpty) {
      return '-';
    }

    return deger.replaceAll('_', ' ');
  }

  static String _tarih(DateTime? tarih) {
    if (tarih == null) {
      return '-';
    }

    return DateFormat('dd.MM.yyyy HH:mm').format(tarih.toLocal());
  }

  static String _para(num? tutar) {
    if (tutar == null) {
      return '-';
    }

    return NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(tutar);
  }
}

// ==================================================================
// FOTOĞRAF GALERİSİ
// ==================================================================

class _FotoGaleri extends StatefulWidget {
  const _FotoGaleri({required this.fotograflar, required this.aracPublicId});

  final List<AracFotograf> fotograflar;
  final String aracPublicId;

  @override
  State<_FotoGaleri> createState() => _FotoGaleriState();
}

class _FotoGaleriState extends State<_FotoGaleri> {
  final ImagePicker _picker = ImagePicker();

  late List<AracFotograf> fotograflar;

  bool yukleniyor = false;

  @override
  void initState() {
    super.initState();

    fotograflar = List.from(widget.fotograflar);
  }

  // ============================================================
  // FOTOĞRAF EKLE
  // ============================================================

  Future<void> fotografKaynakSec() async {
    final kalanHak = 8 - fotograflar.length;

    if (kalanHak <= 0) {
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

                Text('En fazla $kalanHak fotoğraf daha ekleyebilirsiniz.'),

                const SizedBox(height: 12),

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

    if (kaynak == null || !mounted) {
      return;
    }

    // KAMERA
    if (kaynak == ImageSource.camera) {
      final XFile? fotograf = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (fotograf == null || !mounted) {
        return;
      }

      await _fotografYukle(fotograf);
      return;
    }

    // GALERİ - ÇOKLU SEÇİM
    final List<XFile> secilenFotograflar = await _picker.pickMultiImage(
      imageQuality: 90,
    );

    if (!mounted || secilenFotograflar.isEmpty) {
      return;
    }

    final secilecekler = secilenFotograflar.take(kalanHak).toList();

    if (secilenFotograflar.length > kalanHak) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'En fazla $kalanHak fotoğraf seçebilirsiniz. '
            'İlk $kalanHak fotoğraf yüklenecek.',
          ),
        ),
      );
    }

    for (final fotograf in secilecekler) {
      if (!mounted) return;

      await _fotografYukle(fotograf);
    }
  }

  // ============================================================
  // FOTOĞRAF YÜKLE
  // ============================================================

  Future<void> _fotografYukle(XFile fotograf) async {
    if (widget.aracPublicId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Araç public ID bilgisi bulunamadı.')),
      );
      return;
    }

    if (fotograflar.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En fazla 8 fotoğraf ekleyebilirsiniz.')),
      );
      return;
    }

    setState(() {
      yukleniyor = true;
    });

    try {
      await AracService().fotografYukle(
        aracPublicId: widget.aracPublicId,
        dosyaYolu: fotograf.path,
      );

      if (!mounted) return;

      final guncelArac = await AracService().aracDetayiGetir(
        widget.aracPublicId,
      );

      if (!mounted) return;

      setState(() {
        fotograflar = List.from(guncelArac.fotograflar);

        yukleniyor = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf başarıyla eklendi.')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        yukleniyor = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fotoğraf yüklenemedi: $e')));
    }
  }

  // ============================================================
  // FOTOĞRAF SİL
  // ============================================================

  Future<bool> _fotografSil(AracFotograf foto) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Fotoğrafı sil?'),
          content: const Text('Bu fotoğraf kalıcı olarak silinecek.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (onay != true) {
      return false;
    }

    try {
      await AracService().fotografSil(
        aracPublicId: widget.aracPublicId,
        fotografId: foto.id,
      );

      if (!mounted) {
        return false;
      }

      setState(() {
        fotograflar.removeWhere((f) => f.id == foto.id);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fotoğraf silindi.')));

      return true;
    } catch (e) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fotoğraf silinemedi: $e')));

      return false;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final servis = AracService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FOTOĞRAF EKLE BUTONU
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: yukleniyor ? null : fotografKaynakSec,
            icon: yukleniyor
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_a_photo_outlined),
            label: Text(
              yukleniyor
                  ? 'Fotoğraf yükleniyor...'
                  : 'Fotoğraf Ekle (${fotograflar.length}/8)',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // FOTOĞRAF YOK
        if (fotograflar.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 40,
                  color: Colors.grey.shade400,
                ),

                const SizedBox(height: 10),

                Text(
                  'Bu araç için fotoğraf bulunmuyor.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        // FOTOĞRAFLAR
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotograflar.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final foto = fotograflar[index];

                return GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      barrierColor: Colors.black.withValues(alpha: 0.94),
                      builder: (_) => _TamEkranFotoGaleri(
                        fotograflar: fotograflar,
                        baslangicIndex: index,
                        servis: servis,
                        fotografSil: _fotografSil,
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Hero(
                    tag: 'arac-foto-${foto.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        servis.fotografUrl(foto.url),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ==================================================================
// TAM EKRAN FOTOĞRAF GALERİSİ
// ==================================================================

class _TamEkranFotoGaleri extends StatefulWidget {
  const _TamEkranFotoGaleri({
    required this.fotograflar,
    required this.baslangicIndex,
    required this.servis,
    required this.fotografSil,
  });

  final List<AracFotograf> fotograflar;
  final int baslangicIndex;
  final AracService servis;
  final Future<bool> Function(AracFotograf foto) fotografSil;

  @override
  State<_TamEkranFotoGaleri> createState() => _TamEkranFotoGaleriState();
}

class _TamEkranFotoGaleriState extends State<_TamEkranFotoGaleri> {
  late List<AracFotograf> fotograflar;

  late PageController _pageController;

  late int aktifIndex;

  @override
  void initState() {
    super.initState();

    fotograflar = List.from(widget.fotograflar);

    aktifIndex = widget.baslangicIndex;

    _pageController = PageController(initialPage: aktifIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (fotograflar.isEmpty) {
      return const SizedBox.shrink();
    }

    if (aktifIndex >= fotograflar.length) {
      aktifIndex = fotograflar.length - 1;
    }

    final foto = fotograflar[aktifIndex];

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // ======================================================
          // FOTOĞRAFLAR
          // ======================================================
          PageView.builder(
            controller: _pageController,
            itemCount: fotograflar.length,
            onPageChanged: (index) {
              setState(() {
                aktifIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final foto = fotograflar[index];

              return Center(
                child: Hero(
                  tag: 'arac-foto-${foto.id}',
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.network(
                      widget.servis.fotografUrl(foto.url),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 60,
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // ======================================================
          // ÜST BAR
          // ======================================================
          Positioned(
            top: 35,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${aktifIndex + 1} / ${fotograflar.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final silindi = await widget.fotografSil(foto);

                      if (!mounted || !silindi) {
                        return;
                      }

                      setState(() {
                        fotograflar.removeWhere((f) => f.id == foto.id);
                      });

                      if (fotograflar.isEmpty) {
                        Navigator.pop(context);
                        return;
                      }

                      final yeniIndex = aktifIndex >= fotograflar.length
                          ? fotograflar.length - 1
                          : aktifIndex;

                      setState(() {
                        aktifIndex = yeniIndex;
                      });

                      _pageController.jumpToPage(yeniIndex);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // SOL OK
          // ======================================================
          if (aktifIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GaleriOk(
                  icon: Icons.chevron_left,
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),

          // ======================================================
          // SAĞ OK
          // ======================================================
          if (aktifIndex < fotograflar.length - 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: _GaleriOk(
                  icon: Icons.chevron_right,
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),

          // ======================================================
          // ALT BİLGİ
          // ======================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Sağa / sola kaydırarak fotoğraflara bak',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// GALERİ OKU
// ==================================================================

class _GaleriOk extends StatelessWidget {
  const _GaleriOk({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}

// ==================================================================
// BAŞLIK
// ==================================================================

class _Baslik extends StatelessWidget {
  const _Baslik(this.metin);

  final String metin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        metin,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ==================================================================
// BİLGİ KARTI
// ==================================================================

class _BilgiKart extends StatelessWidget {
  const _BilgiKart({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

// ==================================================================
// BİLGİ SATIRI
// ==================================================================

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri(this.baslik, this.deger, {this.cokSatirli = false});

  final String baslik;
  final String deger;
  final bool cokSatirli;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE9EDF2))),
      ),
      child: Row(
        crossAxisAlignment: cokSatirli
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              baslik,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              deger,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DURUM ROZETİ
// ==================================================================

class _DurumRozeti extends StatelessWidget {
  const _DurumRozeti({
    required this.iceride,
    required this.renk,
    this.darkBackground = false,
  });

  final bool iceride;
  final Color renk;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: darkBackground
            ? Colors.white.withValues(alpha: 0.14)
            : renk.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
          ),

          const SizedBox(width: 6),

          Text(
            iceride ? 'İÇERİDE' : 'ÇIKIŞ YAPTI',
            style: TextStyle(
              color: darkBackground ? Colors.white : renk,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ÜST KART ETİKETİ
// ==================================================================

class _Etiket extends StatelessWidget {
  const _Etiket({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
