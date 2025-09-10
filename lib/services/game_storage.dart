import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  static Future<void> saveGame(String fen, bool isWhiteTurn, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fen', fen);
    await prefs.setBool('isWhiteTurn', isWhiteTurn);
    await prefs.setString('mode', mode);
  }

  static Future<Map<String, dynamic>?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final fen = prefs.getString('fen');
    final isWhiteTurn = prefs.getBool('isWhiteTurn');
    final mode = prefs.getString('mode');

    if (fen != null && isWhiteTurn != null && mode != null) {
      return {
        'fen': fen,
        'isWhiteTurn': isWhiteTurn,
        'mode': mode,
      };
    }
    return null;
  }

  static Future<void> clearGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fen');
    await prefs.remove('isWhiteTurn');
    await prefs.remove('mode');
  }

  static bool validateGameData(Map<String, dynamic>? data) {
    if (data == null) return false;
    
    if (!data.containsKey('fen') || data['fen'] == null) return false;
    if (!data.containsKey('isWhiteTurn') || data['isWhiteTurn'] == null) return false;
    if (!data.containsKey('mode') || data['mode'] == null) return false;
    
    final validModes = ['computer', 'local', 'online'];
    if (!validModes.contains(data['mode'])) return false;
    
    return true;
  }
}
