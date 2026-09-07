import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

/// Domain kontraktining yagona implementatsiyasi.
///
/// Vazifasi: remote va local manbalarni muvofiqlashtirish va **barcha**
/// exception'larni [Failure] ga aylantirish. Bu qatlamdan yuqoriga
/// hech qachon exception chiqmasligi kerak.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  }) : _remote = remote,
       _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? fullName,
    String? timezone,
  }) {
    return _guard(() async {
      await _remote.register(
        email: email,
        password: password,
        fullName: fullName,
        timezone: timezone,
      );
      // Backend `/register` token qaytarmaydi — darhol login qilamiz,
      // shunda foydalanuvchi parolni ikkinchi marta yozmaydi.
      return _authenticate(email: email, password: password);
    });
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) {
    return _guard(() => _authenticate(email: email, password: password));
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() {
    return _guard(() async {
      final user = await _remote.getMe();
      await _local.cacheUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? timezone,
  }) {
    return _guard(() async {
      final user = await _remote.updateMe(
        fullName: fullName,
        timezone: timezone,
      );
      await _local.cacheUser(user);
      return user;
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    // Refresh tokenни serverда bekor qilamiz (best-effort) — shu qurilma
    // sessiyasi o'chadi. Internet bo'lmasa ham lokal chiqishни to'xtatmaymiz.
    try {
      final refreshToken = await _local.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _remote.logout(refreshToken);
      }
    } on Exception catch (_) {
      // Serverга yetib bormasa mayli — lokal tokenlarni baribir o'chiramiz.
    }
    await _local.clearSession();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, User?>> restoreSession() async {
    try {
      final token = await _local.getToken();
      // Na access, na refresh amal qilsa — sessiyani tiklab bo'lmaydi.
      if (token == null || (token.isExpired && token.isRefreshExpired)) {
        await _local.clearSession();
        return const Right(null);
      }

      // Access eskirgan bo'lsa ham `/me` ni chaqiramiz — interceptor kerak
      // bo'lganда avval `/auth/refresh` qiladi. Refresh ham o'lik bo'lsa,
      // 401 qaytadi va quyidagi `catch` sessiyani tozalaydi.

      // Token bor — lekin foydalanuvchi bloklangan yoki o'chirilgan bo'lishi
      // mumkin. Yagona ishonchli tekshiruv — `/me`.
      final user = await _remote.getMe();
      await _local.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await _local.clearSession();
        return const Right(null);
      }
      return Left(_mapServer(e));
    } on NetworkException {
      // Internet yo'q — cache'dagi user bilan offline ishlashga ruxsat beramiz.
      return Right(await _safeCachedUser());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      return Right(await _local.getUser());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  // --- Ichki yordamchilar ---

  /// Login qilib, tokenni saqlaydi va profilni oladi.
  Future<UserModel> _authenticate({
    required String email,
    required String password,
  }) async {
    final token = await _remote.login(email: email, password: password);
    // Tokenni `/me` dan **oldin** saqlaymiz — interceptor uni o'sha so'rovga
    // qo'shishi kerak.
    await _local.cacheToken(token);
    final user = await _remote.getMe();
    await _local.cacheUser(user);
    return user;
  }

  Future<UserModel?> _safeCachedUser() async {
    try {
      return await _local.getUser();
    } on CacheException {
      return null;
    }
  }

  /// Barcha exception turlarini bitta joyda `Failure` ga aylantiradi.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(_mapServer(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Failure _mapServer(ServerException e) {
    switch (e.statusCode) {
      case 401:
        return UnauthorizedFailure(e.message);
      case 403:
        return ForbiddenFailure(e.message);
      case 409:
        return ConflictFailure(e.message);
      case 422:
        return ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        );
      default:
        if (e.statusCode >= 500) return ServerFailure(e.message);
        return UnknownFailure(e.message);
    }
  }
}
