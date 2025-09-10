import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../repositories/user_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState>{
  final UserRepository repo;

  LoginBloc(this.repo) : super(Initial()){
    on<LoginRequest>(_onLoginRequest);
    on<RegisterRequest>(_onRegisterRequest);
    on<LogoutRequest>(_onLogoutRequest);
  } 

  Future<void> _onLoginRequest(LoginRequest event, Emitter<LoginState> emit) async{
    emit(Loading());
    try{
      final user = await repo.login(event.email, event.password);
      if(user != null){
        emit(Authenticated(user.uid));
      }
      else{
        emit(Error("User not found!"));
      }
    }
    catch (e){
      emit(Error("Login failed: ${e.toString()}"));
    }
  }

  Future<void> _onRegisterRequest(RegisterRequest event, Emitter<LoginState> emit) async{
    emit(Loading());
    try {
      final user = await repo.register(event.email, event.password, event.name);
      emit(Authenticated(user.uid));
    }
    catch(e){
      emit(Error("Register failed: ${e.toString()}"));
    }
  }

  Future<void> _onLogoutRequest(LogoutRequest event, Emitter<LoginState> emit) async{
    await repo.logout();

    emit(Unauthenticated());
  }

}