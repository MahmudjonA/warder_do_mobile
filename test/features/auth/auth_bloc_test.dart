import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warder_do_mobile/core/error/failures.dart';
import 'package:warder_do_mobile/core/network/session_notifier.dart';
import 'package:warder_do_mobile/features/auth/domain/entities/user.dart';
import 'package:warder_do_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/get_current_user.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/login_user.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/logout_user.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/register_user.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/restore_session.dart';
import 'package:warder_do_mobile/features/auth/domain/usecases/update_profile.dart';
import 'package:warder_do_mobile/features/auth/presentation/bloc/auth_bloc.dart';

final tUser = User(
  id: 'id-1',
  email: 'ali@example.com',
  fullName: 'Ali',
  isActive: true,
  timezone: 'Asia/Tashkent',
  createdAt: DateTime.utc(2026, 9, 3),
);

/// Domain kontraktining soxta implementatsiyasi — bloc uchun shu kifoya.
class FakeAuthRepository implements AuthRepository {
  Either<Failure, User> loginResult = Right(tUser);
  Either<Failure, User> registerResult = Right(tUser);
  Either<Failure, User> currentUserResult = Right(tUser);
  Either<Failure, User> updateResult = Right(tUser);
  Either<Failure, User?> restoreResult = Right(tUser);

  int logoutCalls = 0;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async => loginResult;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? fullName,
    String? timezone,
  }) async => registerResult;

  @override
  Future<Either<Failure, User>> getCurrentUser() async => currentUserResult;

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? timezone,
  }) async => updateResult;

  @override
  Future<Either<Failure, Unit>> logout() async {
    logoutCalls++;
    return const Right(unit);
  }

  @override
  Future<Either<Failure, User?>> restoreSession() async => restoreResult;

  @override
  Future<Either<Failure, User?>> getCachedUser() async => Right(tUser);
}

void main() {
  late FakeAuthRepository repository;
  late SessionNotifier sessionNotifier;
  late AuthBloc bloc;

  setUp(() {
    repository = FakeAuthRepository();
    sessionNotifier = SessionNotifier();
    bloc = AuthBloc(
      registerUser: RegisterUser(repository),
      loginUser: LoginUser(repository),
      logoutUser: LogoutUser(repository),
      getCurrentUser: GetCurrentUser(repository),
      updateProfile: UpdateProfile(repository),
      restoreSession: RestoreSession(repository),
      sessionNotifier: sessionNotifier,
    );
  });

  tearDown(() async {
    await bloc.close();
    await sessionNotifier.dispose();
  });

  test('boshlang’ich holat unknown', () {
    expect(bloc.state.status, AuthStatus.unknown);
    expect(bloc.state.user, isNull);
  });

  group('AuthStarted', () {
    test('sessiya bor → authenticated', () async {
      bloc.add(const AuthStarted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.authenticated && s.user == tUser,
          ),
        ),
      );
    });

    test('sessiya yo’q → unauthenticated', () async {
      repository.restoreResult = const Right(null);
      bloc.add(const AuthStarted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>((s) => s.status == AuthStatus.unauthenticated),
        ),
      );
    });

    test('xatolik bo’lsa ham foydalanuvchini bezovta qilmaydi', () async {
      repository.restoreResult = const Left(NetworkFailure());
      bloc.add(const AuthStarted());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.unauthenticated && s.failure == null,
          ),
        ),
      );
    });
  });

  group('AuthLoginSubmitted', () {
    test('muvaffaqiyat: isSubmitting → authenticated', () async {
      bloc.add(
        const AuthLoginSubmitted(
          email: 'ali@example.com',
          password: 'supersecret1',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsInOrder([
          predicate<AuthState>((s) => s.isSubmitting),
          predicate<AuthState>(
            (s) =>
                !s.isSubmitting &&
                s.status == AuthStatus.authenticated &&
                s.user == tUser,
          ),
        ]),
      );
    });

    test('xato parol: failure va noticeId oshadi', () async {
      repository.loginResult = const Left(UnauthorizedFailure());

      bloc.add(
        const AuthLoginSubmitted(email: 'ali@example.com', password: 'x'),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) =>
                !s.isSubmitting &&
                s.failure is UnauthorizedFailure &&
                s.noticeId == 1 &&
                s.status != AuthStatus.authenticated,
          ),
        ),
      );
    });

    test('bir xil xatolik ikki marta kelsa noticeId farqlanadi', () async {
      repository.loginResult = const Left(UnauthorizedFailure());

      bloc.add(const AuthLoginSubmitted(email: 'a@b.uz', password: 'x'));
      await bloc.stream.firstWhere((s) => s.noticeId == 1);

      bloc.add(const AuthLoginSubmitted(email: 'a@b.uz', password: 'x'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<AuthState>((s) => s.noticeId == 2)),
      );
    });
  });

  group('AuthRegisterSubmitted', () {
    test('422 xatosida maydon xatolari state’ga tushadi', () async {
      repository.registerResult = const Left(
        ValidationFailure(fieldErrors: {'password': 'too short'}),
      );

      bloc.add(const AuthRegisterSubmitted(email: 'a@b.uz', password: 'short'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>((s) => s.fieldErrors['password'] == 'too short'),
        ),
      );
    });
  });

  group('AuthProfileUpdated', () {
    test('muvaffaqiyatda success xabari chiqadi', () async {
      repository.updateResult = Right(tUser.copyWith(timezone: 'UTC'));

      bloc.add(const AuthProfileUpdated(timezone: 'UTC'));

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) =>
                s.successMessage != null &&
                s.user?.timezone == 'UTC' &&
                !s.isSubmitting,
          ),
        ),
      );
    });
  });

  group('sessiya tugashi', () {
    test('SessionNotifier signal bersa unauthenticated bo’ladi', () async {
      bloc.add(const AuthStarted());
      await bloc.stream.firstWhere((s) => s.status == AuthStatus.authenticated);

      sessionNotifier.notifyExpired();

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.unauthenticated && s.failure != null,
          ),
        ),
      );
    });
  });

  group('AuthLogoutRequested', () {
    test('repository chaqiriladi va holat tozalanadi', () async {
      bloc.add(const AuthStarted());
      await bloc.stream.firstWhere((s) => s.status == AuthStatus.authenticated);

      bloc.add(const AuthLogoutRequested());

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<AuthState>(
            (s) => s.status == AuthStatus.unauthenticated && s.user == null,
          ),
        ),
      );
      expect(repository.logoutCalls, 1);
    });
  });
}
