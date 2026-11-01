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

  static String playerName(int i) => _p?.getString('name$i') ?? '';

  static Future<void> setPlayerName(int i, String v) async {
    await _p?.setString('name$i', v);
  }
}
