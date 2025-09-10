
class UserModel {
  final String uid;
  final String email;
  final String username;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
  });

  Map<String, dynamic> toJson(){
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json){
    return UserModel(
      uid: json["uid"],
      email: json["email"],
      username: json["username"],    
      );
  }
}
