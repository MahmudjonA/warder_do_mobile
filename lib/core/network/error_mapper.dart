import 'package:dio/dio.dart';

import '../constants/app_strings.dart';
import '../error/exceptions.dart';

/// `DioException` ni loyihaning o'z exception'lariga aylantiradi.
///
/// FastAPI ikki xil xato formatidan foydalanadi:
///   * oddiy xato  — `{"detail": "Incorrect email or password"}`
///   * 422         — `{"detail": [{"loc": ["body","password"], "msg": "..."}]}`
/// Ikkalasini ham shu yerda bitta ko'rinishga keltiramiz.
class ErrorMapper {
  const ErrorMapper._();

  static Exception map(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(AppStrings.errTimeout);
      case DioExceptionType.transformTimeout:
        // Javob keldi, lekin uni parse qilish cho'zilib ketdi.
        return const NetworkException(AppStrings.errTimeout);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const NetworkException(AppStrings.errNoInternet);
      case DioExceptionType.cancel:
        return const NetworkException(AppStrings.errUnknown);
      case DioExceptionType.badCertificate:
        return const NetworkException(AppStrings.errServer);
      case DioExceptionType.badResponse:
        final response = e.response;
        final status = response?.statusCode ?? 500;
        return ServerException(
          statusCode: status,
          message: _messageFor(status, response?.data),
          fieldErrors: _fieldErrors(response?.data),
        );
    }
  }

  static String _messageFor(int status, dynamic data) {
    final detail = data is Map<String, dynamic> ? data['detail'] : null;

    // 422 da detail — ro'yxat; foydalanuvchiga umumiy matn yaxshiroq,
    // aniqlik esa maydonlar ostida ko'rsatiladi.
    if (detail is String && detail.isNotEmpty) {
      return _localize(status, detail);
    }
    return _localize(status, null);
  }

  /// Backend matnlari ingliz tilida — foydalanuvchi ko'radigan joyda
  /// ularni o'zbekchaga almashtiramiz. Noma'lum holatlarda umumiy matn.
  static String _localize(int status, String? detail) {
    switch (status) {
      case 401:
        return AppStrings.errInvalidCredentials;
      case 403:
        return AppStrings.errAccountBlocked;
      case 409:
        return AppStrings.errEmailTaken;
      case 422:
        return AppStrings.errValidation;
      default:
        if (status >= 500) return AppStrings.errServer;
        return detail ?? AppStrings.errUnknown;
    }
  }

  /// `loc: ["body", "password"]` dan `{"password": "..."}` yasaydi.
  static Map<String, String> _fieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};
    final detail = data['detail'];
    if (detail is! List) return const {};

    final result = <String, String>{};
    for (final item in detail) {
      if (item is! Map) continue;
      final loc = item['loc'];
      final msg = item['msg'];
      if (loc is! List || loc.isEmpty || msg is! String) continue;
      final field = loc.last.toString();
      result.putIfAbsent(field, () => msg);
    }
    return result;
  }
}
