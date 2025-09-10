import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> register(String email, String passwd, String name) async{
    final result = await _auth.createUserWithEmailAndPassword(
      email: email, password: passwd);

    final user = UserModel(
      uid: result.user!.uid,
      email: email,
      username: name,
    );

    _auth.currentUser;
     
    await _firestore.collection("users").doc(user.uid).set(user.toJson());

    return user;
  }

  Future<User?> login(String email, String passwd) async{
    final result = await _auth.signInWithEmailAndPassword(
      email: email, password: passwd);

    return result.user;
  }

  Future<void> logout() async{
    await _auth.signOut();
  }
}