import 'package:chess_game/pages/online_play.dart';
import 'package:chess_game/utils/language_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinGame extends StatelessWidget {
    const JoinGame({super.key});

    @override
    Widget build(BuildContext context) {
        final user = FirebaseAuth.instance.currentUser!;
        Future<String> getOwnerName(id) async{
            final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
            final name = doc.data()!['username'];

            return name;
        }

        return Scaffold(
            appBar: AppBar(
                title: Consumer<LanguageManager>(
                  builder: (context, languageManager, child) {
                    return Text(
                      AppLocalizations.translate('join_game_title', languageManager.locale),
                      style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                    );
                  },
                ),
                backgroundColor: Colors.blue,
            ),
            body: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection("games").where("status", isEqualTo: "waiting").snapshots(), 
                            builder: (context, snapshot){
                                if(!snapshot.hasData) return Center(child: CircularProgressIndicator());

                                final docs = snapshot.data!.docs;
                                if (docs.isEmpty) return Center(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Consumer<LanguageManager>(
                                              builder: (context, languageManager, child) {
                                                return Text(
                                                  AppLocalizations.translate('no_games_found', languageManager.locale),
                                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                                );
                                              },
                                            ),
                                            Consumer<LanguageManager>(
                                              builder: (context, languageManager, child) {
                                                return Text(
                                                  AppLocalizations.translate('ask_friend_create', languageManager.locale),
                                                  style: TextStyle(color: Colors.grey.shade600),
                                                );
                                              },
                                            ),
                                        ],
                                    ),
                                );

                                return ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index){
                                        final doc = docs[index];
                                        final ownerId = doc['player1'];

                                        return FutureBuilder<String>(
                                            future: getOwnerName(ownerId),
                                            builder: (context, snapshot){
                                                final name = snapshot.data ?? "Loading ...";
                                                return Card(
                                                    margin: EdgeInsets.symmetric(vertical: 4),
                                                    child: ListTile(
                                                        leading: CircleAvatar(
                                                            child: Icon(Icons.person),
                                                        ),
                                                        title: Consumer<LanguageManager>(
                                                          builder: (context, languageManager, child) {
                                                            return Text(
                                                              "$name${AppLocalizations.translate('names_game', languageManager.locale)}",
                                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                                            );
                                                          },
                                                        ),
                                                        subtitle: Consumer<LanguageManager>(
                                                          builder: (context, languageManager, child) {
                                                            return Text(
                                                              AppLocalizations.translate('waiting_for_opponent_game', languageManager.locale),
                                                            );
                                                          },
                                                        ),
                                                        trailing: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                            ),
                                                            child: Consumer<LanguageManager>(
                                                              builder: (context, languageManager, child) {
                                                                return Text(
                                                                  AppLocalizations.translate('join', languageManager.locale),
                                                                );
                                                              },
                                                            ),
                                                            onPressed: () async {
                                                                if(context.mounted)
                                                                Navigator.pushReplacement(context, MaterialPageRoute(
                                                                    builder: (_) => OnlinePlay(gameId: doc.id),
                                                                ));
                                                                await FirebaseFirestore.instance.collection("games").doc(doc.id).update({
                                                                'player2': user.uid,
                                                                'status': 'started',
                                                                });
                                                            },
                                                        ),
                                                    ),
                                                );
                                            },
                                        );
                                    },
                                );
                            },
                        ),
                    ),
                ),
            ),
        );
    }
}