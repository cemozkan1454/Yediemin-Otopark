import 'package:flutter/material.dart';

import '../services/arac_service.dart';

class TarifelerSayfasi extends StatefulWidget {
  const TarifelerSayfasi({super.key});

  @override
  State<TarifelerSayfasi> createState() => _TarifelerSayfasiState();
}

class _TarifelerSayfasiState extends State<TarifelerSayfasi> {
  final AracService _aracService = AracService();

  List<Map<String, dynamic>> _tarifeler = [];

  bool _yukleniyor = true;

  // ============================================================
  // RENKLER
  // ============================================================

  static const Color lacivert = Color(0xFF0D1B2A);
  static const Color mavi = Color(0xFF285A96);
  static const Color arkaPlan = Color(0xFFF4F7FB);
  static const Color acikMavi = Color(0xFFF0F4F9);
  static const Color griYazi = Color(0xFF718096);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _tarifeleriYukle();
  }

  // ============================================================
  // TARİFELERİ YÜKLE
  // ============================================================

  Future<void> _tarifeleriYukle() async {
    try {
      final tarifeler = await _aracService.tarifeleriGetir();

      final siralama = [
        'OTOMOBIL',
        'MOTOSIKLET',
        'ELEKTRIKLI_BISIKLET',
        'KAMYONET',
        'KAMYON',
        'TIR',
        'TRAKTOR',
        'ROMORK',
      ];

      tarifeler.sort((a, b) {
        final aTuru = a['aracTuru']?.toString() ?? '';
        final bTuru = b['aracTuru']?.toString() ?? '';

        return siralama.indexOf(aTuru).compareTo(siralama.indexOf(bTuru));
      });

      if (!mounted) return;

      setState(() {
        _tarifeler = tarifeler;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _yukleniyor = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tarifeler yüklenemedi: $e')));
    }
  }

  // ============================================================
  // TARİFE DÜZENLE
  // ============================================================

  Future<void> _tarifeDuzenle(Map<String, dynamic> tarife) async {
    final id = tarife['id'];

    if (id == null) return;

    final aracTuru = tarife['aracTuru']?.toString() ?? '';

    final mevcutUcret = (tarife['gunlukUcret'] as num?)?.toDouble() ?? 0;

    final yeniUcret = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final controller = TextEditingController(
          text: mevcutUcret.toStringAsFixed(2),
        );

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            '${_aracTuruAdi(aracTuru)} Tarifesi',
            style: const TextStyle(
              color: lacivert,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Günlük ücret',
              suffixText: '₺',
              filled: true,
              fillColor: arkaPlan,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: mavi, width: 1.5),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: griYazi, fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: lacivert,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                final temiz = controller.text.trim().replaceAll(',', '.');

                final deger = double.tryParse(temiz);

                if (deger == null || deger < 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Geçerli bir ücret giriniz.')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(deger);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (!mounted || yeniUcret == null) {
      return;
    }

    try {
      await _aracService.tarifeGuncelle(
        id: (id as num).toInt(),
        aracTuru: aracTuru,
        gunlukUcret: yeniUcret,
      );

      if (!mounted) return;

      await _tarifeleriYukle();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_aracTuruAdi(aracTuru)} tarifesi güncellendi.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Tarife güncellenemedi: $e')));
    }
  }

  // ============================================================
  // ARAÇ TÜRÜ ADI
  // ============================================================

  String _aracTuruAdi(String aracTuru) {
    switch (aracTuru) {
      case 'OTOMOBIL':
        return 'Otomobil';

      case 'MOTOSIKLET':
        return 'Motosiklet';

      case 'KAMYONET':
        return 'Kamyonet';

      case 'TIR':
        return 'Tır';

      case 'ELEKTRIKLI_BISIKLET':
        return 'Elektrikli Bisiklet';

      case 'TRAKTOR':
        return 'Traktör';

      case 'ROMORK':
        return 'Römork';

      default:
        return aracTuru.replaceAll('_', ' ');
    }
  }

  // ============================================================
  // ARAÇ İKONU
  // ============================================================

  IconData _aracIkonu(String aracTuru) {
    switch (aracTuru) {
      case 'MOTOSIKLET':
        return Icons.two_wheeler_rounded;

      case 'KAMYONET':
        return Icons.local_shipping_outlined;

      case 'TIR':
        return Icons.fire_truck_outlined;

      case 'ELEKTRIKLI_BISIKLET':
        return Icons.electric_bike_outlined;

      case 'TRAKTOR':
        return Icons.agriculture_outlined;

      case 'ROMORK':
        return Icons.rv_hookup_outlined;

      case 'OTOMOBIL':
      default:
        return Icons.directions_car_filled_outlined;
    }
  }

  // ============================================================
  // ARAÇ İKON KUTUSU
  // ============================================================

  Widget _aracIkonKutusu(String aracTuru) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: acikMavi,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_aracIkonu(aracTuru), color: lacivert, size: 24),
    );
  }

  // ============================================================
  // TARİFE KARTI
  // ============================================================

  Widget _tarifeKarti(Map<String, dynamic> tarife) {
    final aracTuru = tarife['aracTuru']?.toString() ?? '';

    final ucret = (tarife['gunlukUcret'] as num?)?.toDouble() ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          children: [
            // İKON
            _aracIkonKutusu(aracTuru),

            const SizedBox(width: 14),

            // BİLGİ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aracTuruAdi(aracTuru),
                    style: const TextStyle(
                      color: lacivert,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Günlük otopark ücreti',
                    style: TextStyle(color: griYazi, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ÜCRET
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${ucret.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: lacivert,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '/gün',
                  style: TextStyle(
                    color: griYazi,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 10),

            // DÜZENLE
            Material(
              color: acikMavi,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _tarifeDuzenle(tarife);
                },
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.edit_outlined, color: lacivert, size: 19),
                ),
              ),
            ),
          ],
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
      backgroundColor: arkaPlan,

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          tooltip: 'Geri',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: lacivert,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Tarifeler',
          style: TextStyle(
            color: lacivert,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: lacivert))
          : RefreshIndicator(
              color: lacivert,
              onRefresh: _tarifeleriYukle,
              child: _tarifeler.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 180),
                        Icon(Icons.payments_outlined, size: 48, color: griYazi),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Henüz tarife bulunamadı.',
                            style: TextStyle(
                              color: griYazi,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      children: [
                        // ==================================================
                        // ÜST BİLGİ
                        // ==================================================
                        const Text(
                          'Tarifeler',
                          style: TextStyle(
                            color: lacivert,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Araç türlerine göre günlük otopark ücretlerini yönetin.',
                          style: TextStyle(color: griYazi, fontSize: 14),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // TARİFE KARTLARI
                        // ==================================================
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Column(
                            children: [
                              for (int i = 0; i < _tarifeler.length; i++) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: _tarifeKarti(_tarifeler[i]),
                                ),

                                if (i != _tarifeler.length - 1)
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.withValues(alpha: 0.12),
                                  ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // ALT BİLGİ KARTI
                        // ==================================================
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF1F8),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  color: lacivert,
                                  size: 21,
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tarife bilgisi',
                                      style: TextStyle(
                                        color: lacivert,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Buradaki ücretler yeni araçların otopark ücret hesaplamasında kullanılır.',
                                      style: TextStyle(
                                        color: griYazi,
                                        fontSize: 12.5,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
