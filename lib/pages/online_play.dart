import 'package:chess_game/utils/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class OnlinePlay extends StatefulWidget {
  final String gameId;
  const OnlinePlay({super.key, required this.gameId});

  @override
  State<OnlinePlay> createState() => _OnlinePlayState();
}

class _OnlinePlayState extends State<OnlinePlay> {
  late DocumentReference gameRef;
  final user = FirebaseAuth.instance.currentUser!;
  int myColor = Squares.white;
  bool flipBoard = false;
  TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    gameRef = FirebaseFirestore.instance.collection('games').doc(widget.gameId);
  }

  void _flip() => setState(() => flipBoard = !flipBoard);

  void checkGameOver(bishop.Game game) async {
    if(game.gameOver){
      final result = game.result!.readable;

      String winner = "";
      final snapshot = await gameRef.get();
      final data = snapshot.data() as Map<String, dynamic>;

      if(game.result!.scoreString == '1-0'){
        winner = data['player1'];
      }
      else if(game.result!.scoreString == '0-1'){
        winner = data['player2'];
      }

      await gameRef.update({
        'status': 'end',
        'winner': winner,
      });


      showDialog(context: context, 
        builder: (_)=> AlertDialog(
          title: Text(result),
        )
      );

      await Future.delayed(Duration(seconds: 3));
      if(mounted){
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    await gameRef.collection('chat').add({
      'sender': user.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Consumer<LanguageManager>(
          builder: (context, languageManager, child) {
            return Text(
              AppLocalizations.translate('online_chess', languageManager.locale),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            );
          },
        ),
        actions: [
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              return Tooltip(
                message: AppLocalizations.translate('flip_board', languageManager.locale),
                child: IconButton(
                  onPressed: _flip,
                  icon: const Icon(Icons.rotate_left),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: gameRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final player1 = data['player1'];
          final current = data['currentPlayer'];

          myColor = (player1 == user.uid) ? Squares.white : Squares.black;
          final isMyTurn = (current == 'player1' && myColor == Squares.white) ||
                           (current == 'player2' && myColor == Squares.black);

          final fen = data['fen'] ?? bishop.Variant.standard().startPosition;
          final game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);
          final state = game.squaresState(myColor);

          Future<void> onMove(Move move) async {
            if (!isMyTurn) return;

            final result = game.makeSquaresMove(move);
            if (result) {
              await gameRef.update({
                'fen': game.fen,
                'lastMove': move.toString(),
                'currentPlayer': myColor == Squares.white ? 'player2' : 'player1',
              });
            }

            checkGameOver(game);
          }

          WidgetsBinding.instance.addPostFrameCallback((_)=> checkGameOver(game));

          return LayoutBuilder(
            builder: (context, constraints) {
              bool useWideLayout = constraints.maxWidth > 800;
              
              if (useWideLayout) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(radius: 25, child: Icon(Icons.person)),
                                  title: Consumer<LanguageManager>(
                                    builder: (context, languageManager, child) {
                                      return Text(
                                        myColor == Squares.white 
                                          ? AppLocalizations.translate('you_white', languageManager.locale)
                                          : AppLocalizations.translate('you_black', languageManager.locale),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      );
                                    },
                                  ),
                                  subtitle: Consumer<LanguageManager>(
                                    builder: (context, languageManager, child) {
                                      return Text(
                                        isMyTurn 
                                          ? AppLocalizations.translate('your_turn', languageManager.locale)
                                          : AppLocalizations.translate('wait_opponent', languageManager.locale),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                AspectRatio(
                                  aspectRatio: 1.0,
                                  child: BoardController(
                                    state: flipBoard ? state.board.flipped() : state.board,
                                    playState: state.state,
                                    pieceSet: PieceSet.merida(),
                                    theme: BoardTheme.brown,
                                    moves: state.moves,
                                    onMove: onMove,
                                    onPremove: onMove,
                                    markerTheme: MarkerTheme(
                                      empty: MarkerTheme.dot,
                                      piece: MarkerTheme.corners(),
                                    ),
                                    promotionBehaviour: PromotionBehaviour.autoPremove,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: Column(
                          children: [
                            Consumer<LanguageManager>(
                              builder: (context, languageManager, child) {
                                return Text(
                                  AppLocalizations.translate('chat', languageManager.locale),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: gameRef.collection('chat').orderBy('timestamp').snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                                  final docs = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      final isMe = data['sender'] == user.uid;
                                      return Align(
                                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(data['text']),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _chatController,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.translate('write_message', context.read<LanguageManager>().locale),
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SizedBox(height: 20),
                    ListTile(
                      leading: CircleAvatar(radius: 25, child: Icon(Icons.person)),
                      title: Consumer<LanguageManager>(
                        builder: (context, languageManager, child) {
                          return Text(
                            myColor == Squares.white 
                              ? AppLocalizations.translate('you_white', languageManager.locale)
                              : AppLocalizations.translate('you_black', languageManager.locale),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                      subtitle: Consumer<LanguageManager>(
                        builder: (context, languageManager, child) {
                          return Text(
                            isMyTurn 
                              ? AppLocalizations.translate('your_turn', languageManager.locale)
                              : AppLocalizations.translate('wait_opponent', languageManager.locale),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BoardController(
                          state: flipBoard ? state.board.flipped() : state.board,
                          playState: state.state,
                          pieceSet: PieceSet.merida(),
                          theme: BoardTheme.brown,
                          moves: state.moves,
                          onMove: onMove,
                          onPremove: onMove,
                          markerTheme: MarkerTheme(
                            empty: MarkerTheme.dot,
                            piece: MarkerTheme.corners(),
                          ),
                          promotionBehaviour: PromotionBehaviour.autoPremove,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: gameRef.collection('chat').orderBy('timestamp').snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                                final docs = snapshot.data!.docs;
                                return ListView.builder(
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data() as Map<String, dynamic>;
                                    final isMe = data['sender'] == user.uid;
                                    return Align(
                                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(data['text']),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.translate('write_message', context.read<LanguageManager>().locale),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send),
                                  onPressed: _sendMessage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          );
        },
      ),
    );
  }
}
