import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/arac.dart';
import '../services/arac_service.dart';

class AracCikisSayfasi extends StatefulWidget {
  const AracCikisSayfasi({super.key, required this.arac});

  final Arac arac;

  @override
  State<AracCikisSayfasi> createState() => _AracCikisSayfasiState();
}

class _AracCikisSayfasiState extends State<AracCikisSayfasi> {
  final AracService _aracService = AracService();

  late Future<Arac> _ucret;

  bool _cikisYapiliyor = false;

  @override
  void initState() {
    super.initState();
    _ucret = Future.value(widget.arac);
  }

  Future<void> _cikisYap(Arac arac) async {
    if (arac.id == null) {
      _mesajGoster('Araç ID bilgisi bulunamadı.');
      return;
    }

    setState(() {
      _cikisYapiliyor = true;
    });

    try {
      await _aracService.aracCikisiYap(arac.id!, DateTime.now());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Araç çıkışı başarıyla tamamlandı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      _mesajGoster('Araç çıkışı yapılamadı:\n$e');
    } finally {
      if (mounted) {
        setState(() {
          _cikisYapiliyor = false;
        });
      }
    }
  }

  Future<void> _cikisOnayiGoster(Arac arac) async {
    final onay = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final renkler = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: renkler.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: renkler.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Araç Çıkışı',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bu aracın çıkışını tamamlamak istediğinize emin misiniz?',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: renkler.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arac.plaka.trim().isEmpty ? 'Plaka yok' : arac.plaka,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (arac.markaModel.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        arac.markaModel,
                        style: TextStyle(color: renkler.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Toplam ücret',
                          style: TextStyle(color: renkler.onSurfaceVariant),
                        ),
                        Text(
                          _para(arac.toplamUcret),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: renkler.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Çıkışı Onayla'),
            ),
          ],
        );
      },
    );

    if (onay == true && mounted) {
      await _cikisYap(arac);
    }
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final simdi = DateTime.now();
    final renkler = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Araç Çıkışı',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<Arac>(
        future: _ucret,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: renkler.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 38,
                        color: renkler.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ücret hesaplanamadı.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () {
                        final publicId = widget.arac.publicId;

                        if (publicId != null && publicId.isNotEmpty) {
                          setState(() {
                            _ucret = _aracService.cikisUcretiHesapla(publicId);
                          });
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tekrar Hesapla'),
                    ),
                  ],
                ),
              ),
            );
          }

          final arac = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              // Araç kartı
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: renkler.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: renkler.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.directions_car_rounded,
                        size: 30,
                        color: renkler.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Çıkış Yapılacak Araç',
                            style: TextStyle(
                              color: renkler.onPrimaryContainer,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            arac.plaka.trim().isEmpty
                                ? 'Plaka yok'
                                : arac.plaka,
                            style: TextStyle(
                              color: renkler.onPrimaryContainer,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (arac.markaModel.trim().isNotEmpty)
                            Text(
                              arac.markaModel,
                              style: TextStyle(
                                color: renkler.onPrimaryContainer.withOpacity(
                                  0.75,
                                ),
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tarih bilgileri
              _Baslik(icon: Icons.schedule_rounded, title: 'Tarih Bilgileri'),

              const SizedBox(height: 10),

              _BilgiKarti(
                children: [
                  _BilgiSatiri(
                    'Giriş tarihi',
                    _tarih(arac.girisTarihi),
                    icon: Icons.login_rounded,
                  ),
                  const Divider(height: 1),
                  _BilgiSatiri(
                    'Çıkış tarihi',
                    DateFormat('dd.MM.yyyy HH:mm').format(simdi),
                    icon: Icons.logout_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Ücret bilgileri
              _Baslik(icon: Icons.payments_rounded, title: 'Ücret Bilgileri'),

              const SizedBox(height: 10),

              _BilgiKarti(
                children: [
                  _BilgiSatiri(
                    'Otopark ücreti',
                    _para(arac.otoparkUcreti),
                    icon: Icons.local_parking_rounded,
                  ),
                  const Divider(height: 1),
                  _BilgiSatiri(
                    'Çekici ücreti',
                    _para(arac.cekiciUcreti),
                    icon: Icons.local_shipping_rounded,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Divider(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: renkler.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: renkler.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Toplam ücret',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _para(arac.toplamUcret),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: renkler.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Çıkış butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _cikisYapiliyor
                      ? null
                      : () => _cikisOnayiGoster(arac),
                  icon: _cikisYapiliyor
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _cikisYapiliyor ? 'Çıkış Yapılıyor...' : 'Çıkışı Tamamla',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  'Çıkışı tamamladıktan sonra araç içeride görünmez.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: renkler.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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

class _Baslik extends StatelessWidget {
  const _Baslik({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 21, color: renkler.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _BilgiKarti extends StatelessWidget {
  const _BilgiKarti({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri(this.baslik, this.deger, {required this.icon});

  final String baslik;
  final String deger;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: renkler.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: renkler.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              baslik,
              style: TextStyle(color: renkler.onSurfaceVariant, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              deger,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
