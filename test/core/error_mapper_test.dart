import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warder_do_mobile/core/constants/app_strings.dart';
import 'package:warder_do_mobile/core/error/exceptions.dart';
import 'package:warder_do_mobile/core/network/error_mapper.dart';

DioException _badResponse(int status, dynamic body) {
  final options = RequestOptions(path: '/auth/login');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  group('ErrorMapper', () {
    test('401 → foydalanuvchiga tushunarli matn', () {
      final result = ErrorMapper.map(
        _badResponse(401, {'detail': 'Incorrect email or password'}),
      );

      expect(result, isA<ServerException>());
      expect((result as ServerException).statusCode, 401);
      expect(result.message, AppStrings.errInvalidCredentials);
    });

    test('409 → email band', () {
      final result =
          ErrorMapper.map(
                _badResponse(409, {'detail': 'Email already registered'}),
              )
              as ServerException;

      expect(result.message, AppStrings.errEmailTaken);
    });

    test('422 → maydonlar bo’yicha xatolar ajratiladi', () {
      final result =
          ErrorMapper.map(
                _badResponse(422, {
                  'detail': [
                    {
                      'loc': ['body', 'password'],
                      'msg': 'String should have at least 8 characters',
                      'type': 'string_too_short',
                    },
                    {
                      'loc': ['body', 'email'],
                      'msg': 'value is not a valid email address',
                      'type': 'value_error',
                    },
                  ],
                }),
              )
              as ServerException;

      expect(result.statusCode, 422);
      expect(
        result.fieldErrors['password'],
        'String should have at least 8 characters',
      );
      expect(result.fieldErrors['email'], 'value is not a valid email address');
    });

    test('500 → umumiy server xatosi', () {
      final result =
          ErrorMapper.map(_badResponse(500, null)) as ServerException;

      expect(result.message, AppStrings.errServer);
    });

    test('connectionError → NetworkException', () {
      final result = ErrorMapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(result, isA<NetworkException>());
    });

    test('timeout → NetworkException, timeout matni bilan', () {
      final result =
          ErrorMapper.map(
                DioException(
                  requestOptions: RequestOptions(path: '/auth/me'),
                  type: DioExceptionType.connectionTimeout,
                ),
              )
              as NetworkException;

      expect(result.message, AppStrings.errTimeout);
    });
  });
}
