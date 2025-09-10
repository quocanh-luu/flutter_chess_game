import 'package:bishop/bishop.dart' as bishop;
import 'package:chess_game/services/game_storage.dart';
import 'package:chess_game/utils/check_game_over.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

class PlayWithFriendPage extends StatefulWidget {
  final String? fen;
  final bool? isWhiteTurn;

  const PlayWithFriendPage({super.key, this.fen, this.isWhiteTurn});

  @override
  State<PlayWithFriendPage> createState() => _PlayWithFriendPageState();
}

class _PlayWithFriendPageState extends State<PlayWithFriendPage> {
  late bishop.Game game;
  late SquaresState state;
  int player = Squares.white;
  bool flipBoard = false;

  @override
  void initState() {
    super.initState();

    if (widget.fen != null && widget.isWhiteTurn != null) {
      game = bishop.Game(fen: widget.fen, variant: bishop.Variant.standard());
      player = widget.isWhiteTurn! ? Squares.white : Squares.black;
    } else {
      game = bishop.Game(variant: bishop.Variant.standard());
      player = Squares.white;
    }

    state = game.squaresState(player);
  }

  void _resetGame([bool ss = true]) {
    game = bishop.Game(variant: bishop.Variant.standard());
    state = game.squaresState(player);
    if (ss) setState(() {});
  }

  void _onMove(Move move) {
    bool result = game.makeSquaresMove(move);
    if (result) {
      setState(() {
        player = 1 - player;
        state = game.squaresState(player);
      });
      _flipBoard();
    }

    checkGameOver(context, game, player, _resetGame);
  }

  void _flipBoard() => setState(() => flipBoard = !flipBoard);

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Play with Friend',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            const String startingFen =
                "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
            if (game.fen.trim() != startingFen) {
              await GameStorage.saveGame(
                game.fen,
                game.turn == Squares.white,
                "local",
              );
            }
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Tooltip(
            message: 'Reset Game',
            child: IconButton(
             onPressed: _resetGame,
             icon: Icon(Icons.restart_alt),
            ),
          ),
          Tooltip(
            message: 'Flip Board',
            child: IconButton(
              onPressed: _flipBoard,
              icon: Icon(Icons.rotate_left),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double availableHeight = constraints.maxHeight;
                  double boardSize = (availableHeight - 150).clamp(200.0, 500.0);
                  
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        leading: CircleAvatar(radius: 20, child: Icon(Icons.person)),
                        title: Consumer<LanguageManager>(
                          builder: (context, languageManager, child) {
                            return Text(
                              player == Squares.white 
                                ? AppLocalizations.translate('whites_turn', languageManager.locale)
                                : AppLocalizations.translate('blacks_turn', languageManager.locale),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: boardSize,
                        width: boardSize,
                        child: BoardController(
                          state: flipBoard ? state.board.flipped() : state.board,
                          playState: state.state,
                          pieceSet: PieceSet.merida(),
                          theme: BoardTheme.brown,
                          moves: state.moves,
                          onMove: _onMove,
                          onPremove: _onMove,
                          markerTheme: MarkerTheme(
                            empty: MarkerTheme.dot,
                            piece: MarkerTheme.corners(),
                          ),
                          promotionBehaviour: PromotionBehaviour.autoPremove,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
