import 'package:chess_game/main.dart';
import 'package:chess_game/pages/join_game.dart';
import 'package:chess_game/pages/login_page.dart';
import 'package:chess_game/pages/play_with_computer.dart';
import 'package:chess_game/pages/play_with_friend.dart';
import 'package:chess_game/pages/waiting_for_opponent.dart';
import 'package:chess_game/utils/theme_manager.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../blocs/login_bloc.dart';
import '../blocs/login_state.dart';
import '../services/game_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  bool hasSavedGame = false;
  Map<String, dynamic>? savedGame;

  @override
  void initState() {
    super.initState();
    checkForSavedGame();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> checkForSavedGame() async {
    final saved = await GameStorage.loadGame();
    final isValid =
        saved != null &&
        saved['fen'] != null &&
        saved['mode'] != null &&
        saved['isWhiteTurn'] != null;

    if (!mounted) return;

    setState(() {
      hasSavedGame = isValid;
      savedGame = isValid ? saved : null;
    });
  }

  Future<void> _playWithCom(BuildContext context) async {
    await GameStorage.clearGame();
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayWithComOptions()),
      );
      await checkForSavedGame();
    }
  }

  Future<void> _playWithFriend(BuildContext context) async {
    await GameStorage.clearGame();
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlayWithFriendPage()),
      );

      await checkForSavedGame();
    }
  }

  Future<void> _onlinePlay(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                if (state is Authenticated) {
                  return const OnlinePlayOptions();
                } else {
                  return const LoginPage();
                }
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageManager>(
          builder: (context, languageManager, child) {
            return Text(
              AppLocalizations.translate('chess_game', languageManager.locale),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            );
          },
        ),
        actions: [
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              return IconButton(
                onPressed: () => languageManager.toggleLanguage(),
                icon: Text(
                  languageManager.isGerman ? 'EN' : 'DE',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                tooltip: languageManager.isGerman 
                  ? AppLocalizations.translate('english', languageManager.locale)
                  : AppLocalizations.translate('german', languageManager.locale),
              );
            },
          ),
          Consumer2<ThemeManager, LanguageManager>(
            builder: (context, themeManager, languageManager, child) {
              return IconButton(
                onPressed: () => themeManager.toggleTheme(),
                icon: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                tooltip: themeManager.isDarkMode 
                  ? AppLocalizations.translate('light_mode', languageManager.locale)
                  : AppLocalizations.translate('dark_mode', languageManager.locale),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int columns = constraints.maxWidth > 600 ? 4 : 2;
                double aspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.85;
                
                return GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: columns,
                  childAspectRatio: aspectRatio,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
          if (hasSavedGame)
            Consumer<LanguageManager>(
              builder: (context, languageManager, child) {
                return buildGameOption(
                  savedGame!['mode'] == 'com'
                      ? AppLocalizations.translate('continue_with_computer', languageManager.locale)
                      : AppLocalizations.translate('continue_local_play', languageManager.locale),
                  Icons.play_arrow,
                  () async {
                await checkForSavedGame();
                if (savedGame != null) {
                  final mode = savedGame!['mode'];
                  final fen = savedGame!['fen'];
                  final isWhiteTurn = savedGame!['isWhiteTurn'];

                  if (mode == 'computer') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PlayWithComputer(
                              difficulty: 2,
                              fen: fen,
                              isWhiteTurn: isWhiteTurn,
                            ),
                      ),
                    );
                  } else if (mode == 'local') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => PlayWithFriendPage(
                              fen: fen,
                              isWhiteTurn: isWhiteTurn,
                            ),
                      ),
                    );
                  }
                }
              },
                );
              },
            ),
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              return buildGameOption(
                AppLocalizations.translate('play_with_computer', languageManager.locale),
                Icons.computer,
                () async => await _playWithCom(context),
              );
            },
          ),
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              return buildGameOption(
                AppLocalizations.translate('local_play', languageManager.locale),
                Icons.people,
                () async => await _playWithFriend(context),
              );
            },
          ),
          Consumer<LanguageManager>(
            builder: (context, languageManager, child) {
              return buildGameOption(
                AppLocalizations.translate('online_play', languageManager.locale),
                Icons.network_wifi,
                () async => await _onlinePlay(context),
              );
            },
          ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildGameOption(String title, IconData icon, VoidCallback onPressed) {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool hasMoreSpace = constraints.maxWidth > 150;
      double iconSize = hasMoreSpace ? 60.0 : 45.0;
      double textSize = hasMoreSpace ? 18.0 : 15.0;
      double cardPadding = hasMoreSpace ? 24.0 : 18.0;
      double spacing = hasMoreSpace ? 16.0 : 12.0;
      
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 3,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: iconSize),
                SizedBox(height: spacing),
                Text(
                  title, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textSize, 
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PlayWithComOptions extends StatelessWidget {
  const PlayWithComOptions({super.key});

  void _play(int difficulty, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayWithComputer(difficulty: difficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Consumer<LanguageManager>(
          builder: (context, languageManager, child) {
            return Text(
              AppLocalizations.translate('play_with_computer_title', languageManager.locale),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            );
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<LanguageManager>(
                  builder: (context, languageManager, child) {
                    return Text(
                      AppLocalizations.translate('choose_difficulty', languageManager.locale),
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _play(2, context),
                    child: Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('easy', languageManager.locale),
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _play(4, context),
                    child: Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('medium', languageManager.locale),
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _play(6, context),
                    child: Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('hard', languageManager.locale),
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnlinePlayOptions extends StatelessWidget {
  const OnlinePlayOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<LanguageManager>(
          builder: (context, languageManager, child) {
            return Text(
              AppLocalizations.translate('online_play_title', languageManager.locale),
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            );
          },
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<LanguageManager>(
                  builder: (context, languageManager, child) {
                    return Text(
                      AppLocalizations.translate('choose_option', languageManager.locale),
                      style: const TextStyle(fontSize: 18),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser!;
                      final gameRef = await FirebaseFirestore.instance
                          .collection("games")
                          .add({
                            'player1': user.uid,
                            'player2': null,
                            'status': 'waiting',
                            'currentPlayer': 'player1',
                            'fen': null,
                            'lastMove': null,
                          });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => WaitingForOpponentPage(gameId: gameRef.id),
                        ),
                      );
                    },
                    child: Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('create_new_game', languageManager.locale),
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const JoinGame()),
                        ),
                    child: Consumer<LanguageManager>(
                      builder: (context, languageManager, child) {
                        return Text(
                          AppLocalizations.translate('join_game', languageManager.locale),
                          style: const TextStyle(fontSize: 16),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
