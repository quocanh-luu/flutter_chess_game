import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static Future<void> sendMessage({
    required String gameId,
    required String senderId,
    required String text,
  }) async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(gameId)
        .collection('chat')
        .add({
      'sender': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
