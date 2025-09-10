import 'package:chess_game/pages/online_play.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';

class WaitingForOpponentPage extends StatefulWidget {
  final String gameId;

  const WaitingForOpponentPage({super.key, required this.gameId});

  @override
  State<WaitingForOpponentPage> createState() => _WaitingForOpponentPageState();
}

class _WaitingForOpponentPageState extends State<WaitingForOpponentPage> {
  late DocumentReference gameDoc;

  @override
  void initState() {
    super.initState();
    gameDoc = FirebaseFirestore.instance.collection('games').doc(widget.gameId);
  }

  @override
  void dispose() {
    gameDoc.get().then((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data['player2'] == null) {
        gameDoc.delete();
      }
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageManager>(
          builder: (context, languageManager, child) {
            return Text(
              AppLocalizations.translate('waiting_for_opponent', languageManager.locale),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            );
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: gameDoc.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (data['player2'] != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => OnlinePlay(gameId: widget.gameId)),
              );
            });
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 64,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 24),
                    Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('waiting_for_opponent_subtitle', languageManager.locale),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('waiting_message', languageManager.locale),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        );
                      },
                    ),
                    SizedBox(height: 24),
                    Flexible(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Board(
                          state: BoardState(board: List.empty()),
                          theme: BoardTheme.brown,
                          pieceSet: PieceSet.merida(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
