import 'package:flutter_test/flutter_test.dart';
import 'package:chess_game/services/game_storage.dart';

void main() {
  group('GameStorage', () {
    test('validateGameData returns true for valid game data', () {
      final validData = {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'mode': 'computer',
        'isWhiteTurn': true,
      };

      expect(GameStorage.validateGameData(validData), isTrue);
    });

    test('validateGameData returns false for missing fen', () {
      final invalidData = {
        'mode': 'computer',
        'isWhiteTurn': true,
      };

      expect(GameStorage.validateGameData(invalidData), isFalse);
    });

    test('validateGameData returns false for null data', () {
      expect(GameStorage.validateGameData(null), isFalse);
    });

    test('validateGameData returns false for invalid mode', () {
      final invalidData = {
        'fen': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
        'mode': 'invalid_mode',
        'isWhiteTurn': true,
      };

      expect(GameStorage.validateGameData(invalidData), isFalse);
    });
  });
}