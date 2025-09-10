import 'dart:math';

import 'package:bishop/bishop.dart' as bishop;
import 'package:chess_game/services/game_storage.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:square_bishop/square_bishop.dart';
import 'package:squares/squares.dart';

import '../utils/check_game_over.dart';

class PlayWithComputer extends StatefulWidget {
  final int difficulty;
  final String? fen;
  final bool? isWhiteTurn;

  const PlayWithComputer({
    super.key,
    required this.difficulty,
    this.fen,
    this.isWhiteTurn,
  });

  @override
  State<PlayWithComputer> createState() => _PlayWithComputerState();
}

class _PlayWithComputerState extends State<PlayWithComputer> {
  late bishop.Game game;
  late SquaresState state;
  int player = Squares.white;
  bool aiThinking = false;
  bool flipBoard = false;
  late bishop.Engine engine;

  @override
  void initState() {
    super.initState();
    if (widget.fen != null && widget.isWhiteTurn != null) {
      game = bishop.Game(fen: widget.fen, variant: bishop.Variant.standard());
      if(widget.isWhiteTurn!) computerMakeMove();
    } else {
      game = bishop.Game(variant: bishop.Variant.standard());
    }

    player = Squares.white;
    engine = bishop.Engine(game: game);
    state = game.squaresState(player);
  }

  void _resetGame([bool ss = true]) {
    game = bishop.Game(variant: bishop.Variant.standard());
    state = game.squaresState(player);
    if (ss) setState(() {});
  }

  void computerMakeMove() async {
    setState(() => aiThinking = true);
    await Future.delayed(
      Duration(milliseconds: Random().nextInt(4750) + 250),
    );
    bishop.EngineResult result = await engine.search(
      maxDepth: widget.difficulty,
    );
    bishop.Move? m = result.move;
    if (m == null) {
      game.makeRandomMove();
    } else {
      game.makeMove(m);
    }
    setState(() {
      aiThinking = false;
      state = game.squaresState(player);
    });
  }

  void _flipBoard() => setState(() => flipBoard = !flipBoard);

  void _onMove(Move move) async {
    bool result = game.makeSquaresMove(move);
    if (result) {
      setState(() => state = game.squaresState(player));
    }
    if (state.state == PlayState.theirTurn && !aiThinking) {
      computerMakeMove();
    }

    checkGameOver(context, game, player, _resetGame);
  }

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
          'Play with Computer',
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
                "computer",
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
                  double boardSize = (availableHeight - 200).clamp(200.0, 500.0);
                  
                  return Column(
                    verticalDirection:
                        flipBoard ? VerticalDirection.down : VerticalDirection.up,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        leading: CircleAvatar(radius: 20, child: Icon(Icons.person)),
                        title: Text("Player 1", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                      ListTile(
                        leading: CircleAvatar(radius: 20, child: Icon(Icons.computer)),
                        title: Consumer<LanguageManager>(
                          builder: (context, languageManager, child) {
                            return Text(
                              AppLocalizations.translate('computer', languageManager.locale),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            );
                          },
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
