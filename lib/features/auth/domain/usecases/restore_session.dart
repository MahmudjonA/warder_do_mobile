import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Ilova ochilganda chaqiriladi: saqlangan sessiya hali amal qiladimi?
///
/// `Right(null)` — sessiya yo'q yoki eskirgan, login ekrani kerak.
class RestoreSession implements UseCase<User?, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) =>
      _repository.restoreSession();
}
