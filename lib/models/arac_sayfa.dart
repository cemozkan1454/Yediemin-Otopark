import 'arac.dart';

class AracSayfa {
  final List<Arac> araclar;
  final bool sonSayfa;

  const AracSayfa({required this.araclar, required this.sonSayfa});

  factory AracSayfa.fromJson(Map<String, dynamic> json) {
    final content = json['content'] as List<dynamic>? ?? [];

    final araclar = content
        .map((item) => Arac.fromJson(item as Map<String, dynamic>))
        .toList();

    return AracSayfa(araclar: araclar, sonSayfa: json['last'] == true);
  }
}
