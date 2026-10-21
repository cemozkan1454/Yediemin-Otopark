import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/arac.dart';
import '../models/arac_sayfa.dart' as sayfa_model;
import '../services/arac_service.dart';
import '../services/son_goruntulenen_service.dart';
import 'arac_detay_sayfasi.dart';

const lacivert = Color(0xFF0D1B2A);
const mavi = Color(0xFF315F91);

class AraclarSayfasi extends StatefulWidget {
  const AraclarSayfasi({super.key, this.baslangicFiltresi});

  final String? baslangicFiltresi;

  @override
  State<AraclarSayfasi> createState() => _AraclarSayfasiState();
}

class _AraclarSayfasiState extends State<AraclarSayfasi> {
  final AracService _aracService = AracService();

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _aramaController = TextEditingController();

  final List<Arac> _araclar = [];

  List<Arac>? _aramaSonuclari;

  int _secilenSekme = 0;
  int _sayfa = 0;

  bool _yukleniyor = false;
  bool _aramaYapiliyor = false;
  bool _dahaFazlaVar = true;

  String? _hata;

  static const int _sayfaBoyutu = 20;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_scrollDinle);

    switch (widget.baslangicFiltresi) {
      case 'ICERIDE':
        _secilenSekme = 1;
        break;
      case 'CIKTI':
        _secilenSekme = 2;
        break;
      case 'TUMU':
      default:
        _secilenSekme = 0;
        break;
    }

    _sayfayiYukle();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollDinle);
    _scrollController.dispose();
    _aramaController.dispose();

    super.dispose();
  }

  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollDinle() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }

    if (_aramaSonuclari != null) {
      return;
    }

    final pozisyon = _scrollController.position;

    if (pozisyon.pixels >= pozisyon.maxScrollExtent - 300) {
      _sonrakiSayfayiYukle();
    }
  }

  // ============================================================
  // SAYFA YÜKLE
  // ============================================================

  Future<void> _sayfayiYukle({bool yenile = false}) async {
    if (_yukleniyor) {
      return;
    }

    if (!_dahaFazlaVar && !yenile) {
      return;
    }

    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      final sayfa_model.AracSayfa sonuc;

      switch (_secilenSekme) {
        case 1:
          sonuc = await _aracService.iceridekiAraclariGetir(
            sayfa: _sayfa,
            boyut: _sayfaBoyutu,
          );
          break;

        case 2:
          sonuc = await _aracService.cikanAraclariGetir(
            sayfa: _sayfa,
            boyut: _sayfaBoyutu,
          );
          break;

        default:
          sonuc = await _aracService.araclariGetir(
            sayfa: _sayfa,
            boyut: _sayfaBoyutu,
          );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        if (yenile) {
          _araclar.clear();
        }

        _araclar.addAll(sonuc.araclar);

        _dahaFazlaVar = !sonuc.sonSayfa;
        _yukleniyor = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _yukleniyor = false;
        _hata = e.toString();
      });
    }
  }

  // ============================================================
  // SONRAKİ SAYFA
  // ============================================================

  Future<void> _sonrakiSayfayiYukle() async {
    if (_yukleniyor || !_dahaFazlaVar) {
      return;
    }

    _sayfa++;

    await _sayfayiYukle();
  }

  // ============================================================
  // YENİLE
  // ============================================================

  Future<void> _yenile() async {
    if (_yukleniyor || _aramaYapiliyor) {
      return;
    }

    _aramaController.clear();

    setState(() {
      _aramaSonuclari = null;
      _sayfa = 0;
      _dahaFazlaVar = true;
      _araclar.clear();
      _hata = null;
    });

    await _sayfayiYukle();

    if (!mounted) {
      return;
    }

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  // ============================================================
  // SEKME DEĞİŞTİR
  // ============================================================

  Future<void> _sekmeDegistir(int index) async {
    if (_yukleniyor || _aramaYapiliyor || index == _secilenSekme) {
      return;
    }

    _aramaController.clear();

    setState(() {
      _secilenSekme = index;
      _aramaSonuclari = null;
      _sayfa = 0;
      _dahaFazlaVar = true;
      _araclar.clear();
      _hata = null;
    });

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }

    await _sayfayiYukle();
  }

  // ============================================================
  // PLAKA ARAMA
  // ============================================================

  Future<void> _plakaAra() async {
    final arama = _normalizePlaka(_aramaController.text);

    if (arama.isEmpty) {
      setState(() {
        _aramaSonuclari = null;
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _aramaYapiliyor = true;
      _hata = null;
    });

    try {
      final sonuc = await _aracService.plakaIleAra(
        plaka: arama,
        sayfa: 0,
        boyut: _sayfaBoyutu,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _aramaSonuclari = sonuc.araclar;
        _aramaYapiliyor = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _aramaYapiliyor = false;
        _hata = e.toString();
        _aramaSonuclari = [];
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Arama yapılamadı: $e')));
    }
  }

  // ============================================================
  // PLAKA NORMALİZE
  // ============================================================

  String _normalizePlaka(String value) {
    return value.trim().toUpperCase().replaceAll(' ', '').replaceAll('-', '');
  }

  // ============================================================
  // ARAMAYI TEMİZLE
  // ============================================================

  void _aramayiTemizle() {
    _aramaController.clear();

    setState(() {
      _aramaSonuclari = null;
      _hata = null;
    });

    FocusScope.of(context).unfocus();
  }

  // ============================================================
  // DETAY
  // ============================================================

  Future<void> _detayaGit(Arac arac) async {
    if (arac.publicId != null && arac.publicId!.isNotEmpty) {
      await SonGoruntulenenService().ekle(arac.publicId!);
    }

    final sonuc = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AracDetaySayfasi(arac: arac)),
    );

    if (sonuc == true) {
      await _yenile();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool aramaModu = _aramaSonuclari != null;

    final List<Arac> gosterilecekAraclar = aramaModu
        ? _aramaSonuclari!
        : _araclar;

    return Scaffold(
      body: Column(
        children: [
          // ======================================================
          // MAVİ HEADER
          // ======================================================
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 20,
              right: 12,
              bottom: 25,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lacivert, mavi],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Geri',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      const Text(
                        'Araçlar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Otoparktaki araçları yönet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: 'Yenile',
                  onPressed: _yukleniyor ? null : _yenile,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),

          // ======================================================
          // ARAMA
          // ======================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aramaController,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) {
                      _plakaAra();
                    },
                    onChanged: (_) {
                      setState(() {});

                      if (_aramaSonuclari != null) {
                        setState(() {
                          _aramaSonuclari = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Plaka ile ara',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _aramaController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _aramayiTemizle,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                SizedBox(
                  height: 54,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [lacivert, mavi],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _aramaYapiliyor ? null : _plakaAra,
                      child: _aramaYapiliyor
                          ? const SizedBox(
                              width: 21,
                              height: 21,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ara'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // ARAMA SONUCU
          // ======================================================
          if (aramaModu)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _aramaSonuclari!.isEmpty
                          ? '"${_aramaController.text}" içeren araç bulunamadı.'
                          : '"${_aramaController.text}" içeren '
                                '${_aramaSonuclari!.length} araç bulundu.',
                      style: TextStyle(
                        color: const Color(0xFF0D1B2A),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: _aramayiTemizle,
                    child: const Text('Temizle'),
                  ),
                ],
              ),
            ),

          // ======================================================
          // SEKMELER + FİLTRE
          // ======================================================
          if (!aramaModu)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text('Tümü'),
                          icon: Icon(Icons.directions_car_outlined),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('İçeride'),
                          icon: Icon(Icons.local_parking_outlined),
                        ),
                        ButtonSegment<int>(
                          value: 2,
                          label: Text('Çıkış'),
                          icon: Icon(Icons.exit_to_app),
                        ),
                      ],
                      selected: {_secilenSekme},
                      onSelectionChanged: (secim) {
                        if (secim.isNotEmpty) {
                          _sekmeDegistir(secim.first);
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  // V2'DE AKTİF EDİLECEK
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // V2: Filtreleme ekranı burada açılacak.
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),
            ),

          // ======================================================
          // LİSTE
          // ======================================================
          Expanded(
            child: RefreshIndicator(
              onRefresh: _yenile,
              child: _hata != null && _araclar.isEmpty && !aramaModu
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 150),

                        const Icon(Icons.cloud_off_outlined, size: 52),

                        const SizedBox(height: 12),

                        const Center(child: Text('Araçlar yüklenemedi.')),

                        const SizedBox(height: 8),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(_hata!, textAlign: TextAlign.center),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: FilledButton.icon(
                            onPressed: _yenile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tekrar dene'),
                          ),
                        ),
                      ],
                    )
                  : aramaModu && _aramaSonuclari!.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),

                        const Icon(Icons.search_off, size: 56),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            '"${_aramaController.text}" '
                            'içeren araç bulunamadı.',
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: OutlinedButton.icon(
                            onPressed: _aramayiTemizle,
                            icon: const Icon(Icons.clear),
                            label: const Text('Aramayı temizle'),
                          ),
                        ),
                      ],
                    )
                  : !aramaModu && _araclar.isEmpty && !_yukleniyor
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 150),

                        const Icon(Icons.directions_car_outlined, size: 54),

                        const SizedBox(height: 12),

                        Center(
                          child: Text(
                            _secilenSekme == 0
                                ? 'Kayıtlı araç bulunmuyor.'
                                : _secilenSekme == 1
                                ? 'İçeride araç bulunmuyor.'
                                : 'Çıkış yapan araç bulunmuyor.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount:
                          gosterilecekAraclar.length +
                          (!aramaModu && _dahaFazlaVar ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (!aramaModu && index >= gosterilecekAraclar.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final arac = gosterilecekAraclar[index];

                        return _AracKarti(
                          arac: arac,
                          onDetay: () => _detayaGit(arac),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ARAÇ KARTI
// ============================================================

class _AracKarti extends StatelessWidget {
  const _AracKarti({required this.arac, required this.onDetay});

  final Arac arac;
  final VoidCallback onDetay;

  @override
  Widget build(BuildContext context) {
    final durumRengi = arac.iceride
        ? Colors.green
        : const Color.fromARGB(255, 218, 0, 0);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetay,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child:
                      arac.kapakFotografi != null &&
                          arac.kapakFotografi!.trim().isNotEmpty
                      ? Image.network(
                          AracService().fotografUrl(arac.kapakFotografi!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _varsayilanIkon(context),
                        )
                      : _varsayilanIkon(context),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arac.plaka,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(arac.markaModel),

                    const SizedBox(height: 4),

                    Text(
                      '${_tur(arac.aracTuru)} · '
                      '${arac.renk?.isNotEmpty == true ? arac.renk : '-'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),

                    if (arac.girisTarihi != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Giriş: '
                        '${DateFormat('dd.MM.yyyy HH:mm').format(arac.girisTarihi!.toLocal())}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: durumRengi.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      arac.iceride ? 'İÇERİDE' : 'ÇIKTI',
                      style: TextStyle(
                        color: durumRengi,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _varsayilanIkon(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.directions_car_outlined,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  static String _tur(String? tur) {
    if (tur == null || tur.isEmpty) {
      return '-';
    }

    return tur.replaceAll('_', ' ');
  }
}
