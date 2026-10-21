import 'package:shared_preferences/shared_preferences.dart';

class SonGoruntulenenService {
  static const String _key = 'son_goruntulenen_araclar';
  static const int _maxArac = 5;

  Future<List<String>> getir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> ekle(String publicId) async {
    final prefs = await SharedPreferences.getInstance();

    final liste = prefs.getStringList(_key) ?? [];

    liste.remove(publicId);
    liste.insert(0, publicId);

    if (liste.length > _maxArac) {
      liste.removeRange(_maxArac, liste.length);
    }

    await prefs.setStringList(_key, liste);
  }

  Future<void> temizle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
