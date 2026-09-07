import 'package:equatable/equatable.dart';

import '../constants/app_strings.dart';

/// Domain qatlamining xatolik tili. UI faqat shularni ko'radi.
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Foydalanuvchiga ko'rsatish uchun tayyor matn.
  final String message;

  /// Forma maydonlari ostida chiqadigan xatolar (asosan 422 dan).
  Map<String, String> get fieldErrors => const {};

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// 500, 502, 503 va shunga o'xshash server tomondagi muammolar.
class ServerFailure extends Failure {
  const ServerFailure([super.message = AppStrings.errServer]);
}

/// 401 — token yo'q, buzuq yoki muddati o'tgan; login'da esa parol noto'g'ri.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = AppStrings.errInvalidCredentials]);
}

/// 403 — `is_active = false`, hisob bloklangan.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = AppStrings.errAccountBlocked]);
}

/// 404 — topilmadi yoki bu ma'lumot boshqa foydalanuvchiniki.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = AppStrings.errNotFound]);
}

/// 409 — email band.
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = AppStrings.errEmailTaken]);
}

/// 422 — Pydantic validatsiyasi. [fieldErrors] forma ostiga tushadi.
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = AppStrings.errValidation,
    Map<String, String> fieldErrors = const {},
  }) : _fieldErrors = fieldErrors,
       super(message);

  final Map<String, String> _fieldErrors;

  @override
  Map<String, String> get fieldErrors => _fieldErrors;
}

/// So'rov serverga yetib bormadi.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = AppStrings.errNoInternet]);
}

/// Lokal saqlashda muammo.
class CacheFailure extends Failure {
  const CacheFailure([super.message = AppStrings.errUnknown]);
}

/// Qolgan hamma narsa.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = AppStrings.errUnknown]);
}
