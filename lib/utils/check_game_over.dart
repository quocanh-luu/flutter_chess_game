import 'package:flutter/material.dart';
import 'package:bishop/bishop.dart' as bishop;

void checkGameOver(BuildContext context, bishop.Game game, int player, VoidCallback onRestart) {
  if (game.gameOver) {
    String message;
    final result = game.result;

    if (result is bishop.WonGame) {
      final winner = result.winner;
      message = winner == 0 ? 'Du hast gewonnen!' : 'Computer gewinnt!';
    } else {
      message = "Remis!";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Spiel beendet'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRestart();
            },
            child: Text('Neu starten'),
          ),
        ],
      ),
    );
  }
}
