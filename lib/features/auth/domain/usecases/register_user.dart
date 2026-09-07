import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Ro'yxatdan o'tish + avtomatik kirish.
class RegisterUser implements UseCase<User, RegisterParams> {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(
      email: params.email.trim().toLowerCase(),
      password: params.password,
      fullName: params.fullName?.trim().isEmpty ?? true
          ? null
          : params.fullName!.trim(),
      timezone: params.timezone,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    this.fullName,
    this.timezone,
  });

  final String email;
  final String password;
  final String? fullName;

  /// IANA nomi. `null` bo'lsa server `UTC` qo'yadi.
  final String? timezone;

  @override
  List<Object?> get props => [email, password, fullName, timezone];
}
