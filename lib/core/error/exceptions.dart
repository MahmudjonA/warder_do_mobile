/// Data qatlamida otiladigan xatoliklar.
///
/// Bular hech qachon domain yoki presentation qatlamiga chiqmaydi —
/// `AuthRepositoryImpl` ularni [Failure] ga aylantiradi.
library;

/// Server 4xx/5xx qaytardi.
class ServerException implements Exception {
  const ServerException({
    required this.statusCode,
    required this.message,
    this.fieldErrors = const {},
  });

  final int statusCode;
  final String message;

  /// FastAPI 422 javobidagi maydonlar bo'yicha xatolar: `{'password': '...'}`.
  final Map<String, String> fieldErrors;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Socket yopiq, DNS topilmadi, timeout — ya'ni so'rov serverga yetib bormadi.
class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Secure storage o'qish/yozishda muammo yoki kutilgan qiymat yo'q.
class CacheException implements Exception {
  const CacheException(this.message);
  final String message;

  @override
  String toString() => 'CacheException: $message';
}
