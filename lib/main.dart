import 'package:flutter/material.dart';

import 'models/arac.dart';
import 'screens/yeni_arac.dart';
import 'screens/araclar_sayfasi.dart';
import 'screens/arac_detay_sayfasi.dart';
import 'screens/tarifeler_sayfasi.dart';
import 'services/arac_service.dart';
import 'services/son_goruntulenen_service.dart';

const lacivert = Color(0xFF0D1B2A);
const mavi = Color(0xFF315F91);

void main() {
  runApp(const YedieminApp());
}

class YedieminApp extends StatelessWidget {
  const YedieminApp({super.key});

  @override
  Widget build(BuildContext context) {
    const lacivert = Color(0xFF0D1B2A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yediemin Otopark',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: lacivert,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// ANA SAYFA
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AracService _aracService = AracService();

  final SonGoruntulenenService _sonGoruntulenenService =
      SonGoruntulenenService();

  List<Arac> _sonGoruntulenenler = [];

  bool _sonGoruntulenenlerYukleniyor = true;
  bool _dashboardYukleniyor = true;

  int _iceride = 0;
  int _bugunGiris = 0;
  int _bugunCikis = 0;

  int _altMenuIndex = 0;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  // ==========================================================
  // VERİLER
  // ==========================================================

  Future<void> _verileriYukle() async {
    await Future.wait([_dashboardYukle(), _sonGoruntulenenleriYukle()]);
  }

  Future<void> _dashboardYukle() async {
    try {
      final response = await _aracService.dashboardOzetiGetir();

      if (!mounted) return;

      setState(() {
        _iceride = response['iceride'] ?? 0;
        _bugunGiris = response['bugunGiris'] ?? 0;
        _bugunCikis = response['bugunCikis'] ?? 0;
        _dashboardYukleniyor = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _dashboardYukleniyor = false;
      });
    }
  }

  Future<void> _sonGoruntulenenleriYukle() async {
    try {
      final publicIdler = await _sonGoruntulenenService.getir();

      final List<Arac> araclar = [];

      for (final publicId in publicIdler) {
        try {
          final arac = await _aracService.aracDetayiGetir(publicId);
          araclar.add(arac);
        } catch (_) {
          // Araç artık bulunmuyorsa geç.
        }
      }

      if (!mounted) return;

      setState(() {
        _sonGoruntulenenler = araclar;
        _sonGoruntulenenlerYukleniyor = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _sonGoruntulenenlerYukleniyor = false;
      });
    }
  }

  Future<void> _yenile() async {
    setState(() {
      _dashboardYukleniyor = true;
      _sonGoruntulenenlerYukleniyor = true;
    });

    await _verileriYukle();
  }

  // ==========================================================
  // ARAÇ DETAY
  // ==========================================================

  Future<void> _aracDetayinaGit(Arac arac) async {
    if (arac.publicId == null || arac.publicId!.isEmpty) {
      return;
    }

    await _sonGoruntulenenService.ekle(arac.publicId!);

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AracDetaySayfasi(arac: arac)),
    );

    await _verileriYukle();
  }

  // ==========================================================
  // YENİ ARAÇ
  // ==========================================================

  Future<void> _yeniArac() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const YeniAracPage()),
    );

    await _verileriYukle();
  }

  // ==========================================================
  // ARAÇLAR
  // ==========================================================

  Future<void> _araclar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AraclarSayfasi()),
    );

    await _verileriYukle();
  }

  // ==========================================================
  // AYARLAR
  // ==========================================================

  Future<void> _ayarlar() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst sürükleme çubuğu
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Başlık
                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Uygulama ve otopark ayarlarını yönetin',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),

                  const SizedBox(height: 26),

                  // =====================================================
                  // TARİFELER
                  // =====================================================
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TarifelerSayfasi(),
                        ),
                      );

                      await _verileriYukle();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          _ayarIkonu(Icons.payments_outlined),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tarifeler',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D1B2A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Araç türlerine göre ücretleri düzenle',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // =====================================================
                  // KULLANICI BİLGİLERİ
                  // =====================================================
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Kullanıcı bilgileri V2 kapsamında eklenecek.',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          _ayarIkonu(Icons.person_outline_rounded),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kullanıcı Bilgileri',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D1B2A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kullanıcı ve hesap bilgileri',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // =====================================================
                  // UYGULAMA HAKKINDA
                  // =====================================================
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Yediemin Otopark',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Yediemin Otopark Yönetim Sistemi',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          _ayarIkonu(Icons.info_outline_rounded),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Uygulama Hakkında',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D1B2A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Yediemin Otopark Yönetim Sistemi',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF475569),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ayarIkonu(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: const Color(0xFF0D1B2A)),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _yenile,
          color: const Color(0xFF0D1B2A),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _ustAlan()),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _istatistikler(),
                    const SizedBox(height: 28),
                    _hizliIslemler(),
                    const SizedBox(height: 30),
                    _sonAraclar(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _altNavigasyon(),
    );
  }

  // ==========================================================
  // ÜST ALAN
  // ==========================================================

  Widget _ustAlan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lacivert, mavi],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_parking_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Text(
                  'Yediemin Otopark',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              IconButton(
                tooltip: 'Yenile',
                onPressed: _yenile,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),

              IconButton(
                tooltip: 'Ayarlar',
                onPressed: _ayarlar,
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text(
            'Hoş geldin 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Otoparkınızın güncel durumu',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          // Büyük içeride kartı
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AraclarSayfasi(baslangicFiltresi: 'ICERIDE'),
                ),
              );

              await _verileriYukle();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3DDC97).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Color(0xFF3DDC97),
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'İçerideki Araçlar',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),

                        _dashboardYukleniyor
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                '$_iceride',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // İSTATİSTİKLER
  // ==========================================================

  Widget _istatistikler() {
    if (_dashboardYukleniyor) {
      return Row(
        children: [
          Expanded(
            child: _istatistikKart(
              'Giriş',
              '-',
              Icons.login_rounded,
              const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _istatistikKart(
              'Çıkış',
              '-',
              Icons.logout_rounded,
              const Color(0xFF16A34A),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _istatistikKart(
            'Bugün Giriş',
            '$_bugunGiris',
            Icons.login_rounded,
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _istatistikKart(
            'Bugün Çıkış',
            '$_bugunCikis',
            Icons.logout_rounded,
            const Color(0xFF16A34A),
          ),
        ),
      ],
    );
  }

  Widget _istatistikKart(
    String baslik,
    String deger,
    IconData ikon,
    Color renk,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(ikon, color: renk, size: 21),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deger,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HIZLI İŞLEMLER
  // ==========================================================

  Widget _hizliIslemler() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _hizliIslem(
                icon: Icons.add_rounded,
                baslik: 'Yeni Araç',
                aciklama: 'Giriş kaydı oluştur',
                renk: const Color(0xFF0D1B2A),
                onTap: _yeniArac,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _hizliIslem(
                icon: Icons.directions_car_outlined,
                baslik: 'Araçlar',
                aciklama: 'Araçları görüntüle',
                renk: const Color(0xFF2563EB),
                onTap: _araclar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _hizliIslem({
    required IconData icon,
    required String baslik,
    required String aciklama,
    required Color renk,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: renk,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(height: 16),

              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                aciklama,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SON ARAÇLAR
  // ==========================================================

  Widget _sonAraclar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Son Görüntülenen Araçlar',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
            ),

            if (_sonGoruntulenenler.isNotEmpty)
              Text(
                '${_sonGoruntulenenler.length}/5',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (_sonGoruntulenenlerYukleniyor)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_sonGoruntulenenler.isEmpty)
          _bosSonAraclar()
        else
          ..._sonGoruntulenenler.map(
            (arac) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _aracKarti(arac),
            ),
          ),
      ],
    );
  }

  Widget _bosSonAraclar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              size: 32,
              color: Color(0xFF0D1B2A),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Henüz araç görüntülenmedi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B2A),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Görüntülediğiniz araçlar burada listelenecek.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _aracKarti(Arac arac) {
    final bool iceride = arac.iceride;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _aracDetayinaGit(arac),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _aracFotografi(arac),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arac.plaka,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      arac.markaModel,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      arac.aracTuru == null || arac.aracTuru!.isEmpty
                          ? '-'
                          : arac.aracTuru!.replaceAll('_', ' '),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: iceride
                          ? const Color(0xFF16A34A).withValues(alpha: 0.10)
                          : const Color.fromARGB(
                              148,
                              255,
                              0,
                              0,
                            ).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      iceride ? 'İÇERİDE' : 'ÇIKTI',
                      style: TextStyle(
                        color: iceride
                            ? const Color(0xFF16A34A)
                            : const Color.fromARGB(255, 255, 0, 0),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 9),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _aracFotografi(Arac arac) {
    final hasPhoto =
        arac.fotograflar.isNotEmpty &&
        arac.fotograflar.first.url.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: 72,
        height: 72,
        child: hasPhoto
            ? Image.network(
                AracService().fotografUrl(arac.fotograflar.first.url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return _varsayilanIkon();
                },
              )
            : _varsayilanIkon(),
      ),
    );
  }

  Widget _varsayilanIkon() {
    return Container(
      color: const Color(0xFFE9EEF5),
      child: const Icon(
        Icons.directions_car_outlined,
        color: Color(0xFF0D1B2A),
        size: 30,
      ),
    );
  }

  // ==========================================================
  // ALT NAVIGATION
  // ==========================================================

  Widget _altNavigasyon() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              // ==================================================
              // ANA SAYFA
              // ==================================================
              Expanded(
                child: _altBarButonu(
                  ikon: Icons.home_outlined,
                  seciliIkon: Icons.home_rounded,
                  baslik: 'Ana Sayfa',
                  index: 0,
                ),
              ),

              // ==================================================
              // ARAÇLAR
              // ==================================================
              Expanded(
                child: _altBarButonu(
                  ikon: Icons.directions_car_outlined,
                  seciliIkon: Icons.directions_car_filled_rounded,
                  baslik: 'Araçlar',
                  index: 1,
                ),
              ),

              // ==================================================
              // ORTADAKİ + İÇİN BOŞLUK
              // ==================================================
              SizedBox(
                width: 70,
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      width: 80,
                      height: 80,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _yeniArac,
                          customBorder: const CircleBorder(),
                          child: Ink(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF0D1B2A), Color(0xFF315F91)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // AYARLAR
              // ==================================================
              Expanded(
                child: _altBarButonu(
                  ikon: Icons.settings_outlined,
                  seciliIkon: Icons.settings_rounded,
                  baslik: 'Ayarlar',
                  index: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // ALT BAR BUTONU
  // ==========================================================

  Widget _altBarButonu({
    required IconData ikon,
    required IconData seciliIkon,
    required String baslik,
    required int index,
  }) {
    final bool secili = _altMenuIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          setState(() {
            _altMenuIndex = index;
          });

          switch (index) {
            case 0:
              break;

            case 1:
              await _araclar();

              if (mounted) {
                setState(() {
                  _altMenuIndex = 0;
                });
              }
              break;

            case 2:
              await _ayarlar();

              if (mounted) {
                setState(() {
                  _altMenuIndex = 0;
                });
              }
              break;
          }
        },
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                secili ? seciliIkon : ikon,
                size: 22,
                color: secili
                    ? const Color(0xFF17365D)
                    : const Color(0xFF9AA8B8),
              ),

              const SizedBox(height: 2),

              Text(
                baslik,
                style: TextStyle(
                  fontSize: 9,
                  height: 1,
                  fontWeight: secili ? FontWeight.w700 : FontWeight.w500,
                  color: secili
                      ? const Color(0xFF17365D)
                      : const Color(0xFF9AA8B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
