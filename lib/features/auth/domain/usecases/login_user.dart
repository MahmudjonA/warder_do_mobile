import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Email + parol bilan kirish.
class LoginUser implements UseCase<User, LoginParams> {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    // Email'ni bu yerda normallashtiramiz: server ham kichik harfga o'tkazadi,
    // lekin bir xil qoidani clientda ushlab turgan ma'qul.
    return _repository.login(
      email: params.email.trim().toLowerCase(),
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}
