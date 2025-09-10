abstract class LoginEvent {}

class LoginRequest extends LoginEvent {
  final String email;
  final String password;

  LoginRequest(this.email, this.password);
}

class RegisterRequest extends LoginEvent {
  final String email;
  final String password;
  final String name;

  RegisterRequest(this.email, this.password, this.name);
}

class LogoutRequest extends LoginEvent{}