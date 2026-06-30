import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleLoginUseCase googleLoginUseCase;
  final SaveUserRoleUseCase saveUserRoleUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleLoginUseCase,
    required this.saveUserRoleUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<SaveRoleEvent>(_onSaveRole);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          if (user.isRoleSelected) {
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthRolePending(user));
          }
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user.isRoleSelected) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthRolePending(user));
        }
      },
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(RegisterParams(
      name: event.name,
      email: event.email,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthRolePending(user)),
    );
  }

  Future<void> _onGoogleLogin(GoogleLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await googleLoginUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSaveRole(SaveRoleEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await saveUserRoleUseCase(SaveRoleParams(uid: event.uid, role: event.role));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase(NoParams());
    emit(AuthUnauthenticated());
  }
}
