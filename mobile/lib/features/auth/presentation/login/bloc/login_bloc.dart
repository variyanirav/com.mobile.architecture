import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/auth/domain/usecases/login_user_use_case.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUserUseCase loginUser;

  String _email = '';
  String _password = '';

  LoginBloc({required this.loginUser}) : super(const LoginInitial()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    _email = event.email;
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    _password = event.password;
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await loginUser(_email, _password);

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user)),
    );
  }
}
