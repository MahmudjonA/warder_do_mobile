import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/session_notifier.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/update_profile.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Butun ilovadagi autentifikatsiya holati.
///
/// Bitta global instansiya sifatida `MultiBlocProvider` da beriladi —
/// router ham, profil ekrani ham shu bloc'ga qaraydi.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required RegisterUser registerUser,
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required GetCurrentUser getCurrentUser,
    required UpdateProfile updateProfile,
    required RestoreSession restoreSession,
    required SessionNotifier sessionNotifier,
  }) : _registerUser = registerUser,
       _loginUser = loginUser,
       _logoutUser = logoutUser,
       _getCurrentUser = getCurrentUser,
       _updateProfile = updateProfile,
       _restoreSession = restoreSession,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterSubmitted>(_onRegister);
    on<AuthProfileUpdated>(_onProfileUpdated);
    on<AuthUserRefreshed>(_onUserRefreshed);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthNoticeCleared>(_onNoticeCleared);

    // Interceptor 401 ko'rsa shu yerdan xabar keladi.
    _expirySubscription = sessionNotifier.onSessionExpired.listen(
      (_) => add(const AuthSessionExpired()),
    );
  }

  final RegisterUser _registerUser;
  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final GetCurrentUser _getCurrentUser;
  final UpdateProfile _updateProfile;
  final RestoreSession _restoreSession;

  late final StreamSubscription<void> _expirySubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.unknown, clearNotice: true));

    final result = await _restoreSession(const NoParams());

    result.fold(
      (failure) => emit(
        // Sessiyani tiklab bo'lmadi — login ekrani. Xatolikni ko'rsatmaymiz:
        // ilova ochilishida snackbar chiqarish bezovta qiladi.
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      ),
      (user) => emit(
        user == null
            ? state.copyWith(
                status: AuthStatus.unauthenticated,
                clearUser: true,
              )
            : state.copyWith(status: AuthStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _loginUser(
      LoginParams(email: event.email, password: event.password),
    );

    _emitAuthResult(result, emit);
  }

  Future<void> _onRegister(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _registerUser(
      RegisterParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        timezone: event.timezone,
      ),
    );

    _emitAuthResult(result, emit);
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _updateProfile(
      UpdateProfileParams(fullName: event.fullName, timezone: event.timezone),
    );

    result.fold(
      (failure) => emit(_withFailure(failure)),
      (user) => emit(
        state.copyWith(
          isSubmitting: false,
          user: user,
          status: AuthStatus.authenticated,
          successMessage: AppStrings.profileSaved,
          noticeId: state.noticeId + 1,
        ),
      ),
    );
  }

  Future<void> _onUserRefreshed(
    AuthUserRefreshed event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _getCurrentUser(const NoParams());

    result.fold(
      (failure) {
        // 401/403 bo'lsa interceptor allaqachon AuthSessionExpired yuboradi.
        // Qolgan xatolarda ekrandagi ma'lumotni buzmaymiz — jimgina o'tamiz.
        if (failure is UnauthorizedFailure || failure is ForbiddenFailure) {
          emit(_loggedOutState(AppStrings.errSessionExpired));
        }
      },
      (user) =>
          emit(state.copyWith(user: user, status: AuthStatus.authenticated)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUser(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onSessionExpired(AuthSessionExpired event, Emitter<AuthState> emit) {
    // Allaqachon chiqib bo'lgan bo'lsa qayta xabar bermaymiz.
    if (state.status == AuthStatus.unauthenticated) return;
    emit(_loggedOutState(AppStrings.errSessionExpired));
  }

  void _onNoticeCleared(AuthNoticeCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearNotice: true));
  }

  // --- Yordamchilar ---

  /// Login va register natijasi bir xil ko'rinishda qayta ishlanadi.
  void _emitAuthResult(Either<Failure, User> result, Emitter<AuthState> emit) {
    result.fold(
      (failure) => emit(_withFailure(failure)),
      (user) => emit(AuthState(status: AuthStatus.authenticated, user: user)),
    );
  }

  AuthState _withFailure(Failure failure) => state.copyWith(
    isSubmitting: false,
    failure: failure,
    noticeId: state.noticeId + 1,
  );

  AuthState _loggedOutState(String message) => AuthState(
    status: AuthStatus.unauthenticated,
    failure: UnauthorizedFailure(message),
    noticeId: state.noticeId + 1,
  );

  @override
  Future<void> close() {
    _expirySubscription.cancel();
    return super.close();
  }
}
