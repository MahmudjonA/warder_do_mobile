import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Har bir use case bitta ish qiladi va `call` orqali chaqiriladi.
///
/// ```dart
/// final result = await loginUseCase(LoginParams(email: e, password: p));
/// result.fold((failure) => ..., (user) => ...);
/// ```
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Parametr talab qilmaydigan use case'lar uchun.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
