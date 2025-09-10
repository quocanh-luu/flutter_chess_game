abstract class LoginState {}

class Initial extends LoginState {}

class Loading extends LoginState {}

class Authenticated extends LoginState {
  final String uid;

  Authenticated(this.uid);
}

class Unauthenticated extends LoginState {}

class Error extends LoginState {
  final String message;

  Error(this.message);
}