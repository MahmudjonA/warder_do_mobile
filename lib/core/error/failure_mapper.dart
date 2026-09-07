import 'package:dartz/dartz.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Data qatlamidagi exception'larni domain qatlamidagi [Failure] ga
/// aylantiruvchi yagona joy.
///
/// Har bir repository'da bir xil `try/catch` blokini takrorlamaslik uchun:
/// ```dart
/// Future<Either<Failure, List<Group>>> getGroups() =>
///     guardApi(() => _remote.getGroups());
/// ```
Future<Either<Failure, T>> guardApi<T>(Future<T> Function() action) async {
  try {
    return Right(await action());
  } on ServerException catch (e) {
    return Left(mapServerException(e));
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  } on CacheException catch (e) {
    return Left(CacheFailure(e.message));
  } on Exception catch (_) {
    return const Left(UnknownFailure());
  }
}

/// HTTP status kodini [Failure] ga moslashtiradi.
Failure mapServerException(ServerException e) {
  switch (e.statusCode) {
    case 401:
      return UnauthorizedFailure(e.message);
    case 403:
      return ForbiddenFailure(e.message);
    case 404:
      // Backend "boshqa odamning ma'lumoti" holatini ham 404 deb qaytaradi —
      // bu ataylab shunday, xavfsizlik uchun.
      return const NotFoundFailure();
    case 409:
      return ConflictFailure(e.message);
    case 422:
      return ValidationFailure(message: e.message, fieldErrors: e.fieldErrors);
    default:
      if (e.statusCode >= 500) return ServerFailure(e.message);
      return UnknownFailure(e.message);
  }
}
