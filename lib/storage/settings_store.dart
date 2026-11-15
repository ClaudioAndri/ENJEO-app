import 'package:shared_preferences/shared_preferences.dart';

/// Sauvegarde locale simple (aucune donnée envoyée en ligne).
class SettingsStore {
  static SharedPreferences? _p;

  static Future<void> init() async {
    try {
      _p = await SharedPreferences.getInstance();
    } catch (_) {
      _p = null;
    }
  }

  static bool get soundOn => _p?.getBool('sound') ?? true;

  static Future<void> setSoundOn(bool v) async {
    await _p?.setBool('sound', v);
  }

  /// Langue choisie ('mg' par défaut).
  static String get lang => _p?.getString('lang') ?? 'mg';

  static Future<void> setLang(String v) async {
    await _p?.setString('lang', v);
  }

  static String playerName(int i) => _p?.getString('name$i') ?? '';

  static Future<void> setPlayerName(int i, String v) async {
    await _p?.setString('name$i', v);
  }
}
