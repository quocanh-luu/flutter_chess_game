import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageManager extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _locale = const Locale('en', 'US');
  
  Locale get locale => _locale;
  
  bool get isGerman => _locale.languageCode == 'de';
  
  LanguageManager() {
    _loadLanguage();
  }
  
  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _locale = languageCode == 'de' ? const Locale('de', 'DE') : const Locale('en', 'US');
    notifyListeners();
  }
  
  void toggleLanguage() async {
    _locale = _locale.languageCode == 'en' ? const Locale('de', 'DE') : const Locale('en', 'US');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _locale.languageCode);
    notifyListeners();
  }
}

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'chess_game': 'Chess Game',
      'play_with_computer': 'Play with computer',
      'local_play': 'Local play',
      'online_play': 'Online play',
      'continue_with_computer': 'Continue with computer',
      'continue_local_play': 'Continue local play',
      'choose_difficulty': 'Choose a difficulty:',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'choose_option': 'Choose an Option:',
      'create_new_game': 'Create new game',
      'join_game': 'Join a game',
      'waiting_for_opponent': 'Waiting for Opponent...',
      'waiting_message': 'Wait until someone joins your game.',
      'no_games_found': 'No games found',
      'ask_friend_create': 'Ask a friend to create a game first',
      'waiting_for_opponent_subtitle': 'Waiting for opponent',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'enter_email': 'Enter your email',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'username': 'Username',
      'enter_username': 'Enter your username',
      'player_1': 'Player 1',
      'computer': 'Computer',
      'whites_turn': "White's Turn",
      'blacks_turn': "Black's Turn",
      'you_white': 'White (You)',
      'you_black': 'Black (You)',
      'your_turn': 'Your turn',
      'wait_opponent': 'Wait for opponent...',
      'online_chess': 'Online Chess',
      'chat': 'Chat',
      'write_message': 'Write a message...',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'german': 'German',
      'english': 'English',
      'reset_game': 'Reset Game',
      'flip_board': 'Flip Board',
      'join': 'Join',
      'play_with_computer_title': 'Play with Computer',
      'online_play_title': 'Online play',
      'join_game_title': 'Join a game',
      'waiting_for_opponent_game': 'Waiting for opponent',
      'names_game': "'s game",
    },
    'de': {
      'chess_game': 'Schach Spiel',
      'play_with_computer': 'Gegen Computer spielen',
      'local_play': 'Lokales Spiel',
      'online_play': 'Online spielen',
      'continue_with_computer': 'Mit Computer fortsetzen',
      'continue_local_play': 'Lokales Spiel fortsetzen',
      'choose_difficulty': 'Schwierigkeitsgrad wählen:',
      'easy': 'Einfach',
      'medium': 'Mittel',
      'hard': 'Schwer',
      'choose_option': 'Option wählen:',
      'create_new_game': 'Neues Spiel erstellen',
      'join_game': 'Spiel beitreten',
      'waiting_for_opponent': 'Warten auf Gegner...',
      'waiting_message': 'Warte, bis sich jemand deinem Spiel anschließt.',
      'no_games_found': 'Keine Spiele gefunden',
      'ask_friend_create': 'Bitte einen Freund, zuerst ein Spiel zu erstellen',
      'waiting_for_opponent_subtitle': 'Warte auf Gegner',
      'login': 'Anmelden',
      'register': 'Registrieren',
      'email': 'E-Mail',
      'enter_email': 'E-Mail eingeben',
      'password': 'Passwort',
      'enter_password': 'Passwort eingeben',
      'username': 'Benutzername',
      'enter_username': 'Benutzername eingeben',
      'player_1': 'Spieler 1',
      'computer': 'Computer',
      'whites_turn': 'Weiß ist am Zug',
      'blacks_turn': 'Schwarz ist am Zug',
      'you_white': 'Weiß (Du)',
      'you_black': 'Schwarz (Du)',
      'your_turn': 'Du bist am Zug',
      'wait_opponent': 'Warte auf Gegner...',
      'online_chess': 'Online Schach',
      'chat': 'Chat',
      'write_message': 'Nachricht schreiben...',
      'light_mode': 'Heller Modus',
      'dark_mode': 'Dunkler Modus',
      'german': 'Deutsch',
      'english': 'Englisch',
      'reset_game': 'Spiel zurücksetzen',
      'flip_board': 'Brett drehen',
      'join': 'Beitreten',
      'play_with_computer_title': 'Gegen Computer spielen',
      'online_play_title': 'Online spielen',
      'join_game_title': 'Spiel beitreten',
      'waiting_for_opponent_game': 'Warte auf Gegner',
      'names_game': 's Spiel',
    },
  };

  static String translate(String key, Locale locale) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

extension BuildContextExtension on BuildContext {
  String tr(String key) {
    final languageManager = Provider.of<LanguageManager>(this, listen: false);
    return AppLocalizations.translate(key, languageManager.locale);
  }
}