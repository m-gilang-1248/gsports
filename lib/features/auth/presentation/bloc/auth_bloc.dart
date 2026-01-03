import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/usecases/check_auth_status.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/update_fcm_token.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatus _checkAuthStatus;
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final LogoutUser _logoutUser;
  final SignInWithGoogle _signInWithGoogle;
  final UpdateFcmToken _updateFcmToken;
  final NotificationService _notificationService;

  AuthBloc(
    this._checkAuthStatus,
    this._loginUser,
    this._registerUser,
    this._logoutUser,
    this._signInWithGoogle,
    this._updateFcmToken,
    this._notificationService,
  ) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthFcmTokenUpdateRequested>(_onFcmTokenUpdateRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _checkAuthStatus(NoParams());
    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      emit(AuthAuthenticated(user));
      add(AuthFcmTokenUpdateRequested());
    });
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _loginUser(
      LoginUserParams(email: event.email, password: event.password),
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      emit(AuthAuthenticated(user));
      add(AuthFcmTokenUpdateRequested());
    });
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _registerUser(
      RegisterUserParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        role: event.role,
      ),
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      emit(AuthAuthenticated(user));
      add(AuthFcmTokenUpdateRequested());
    });
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _signInWithGoogle(
      SignInWithGoogleParams(role: event.role),
    );
    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      emit(AuthAuthenticated(user));
      add(AuthFcmTokenUpdateRequested());
    });
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _logoutUser(NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onFcmTokenUpdateRequested(
    AuthFcmTokenUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _notificationService.getFCMToken();
    if (token != null) {
      await _updateFcmToken(UpdateFcmTokenParams(token: token));
    }
  }
}
