import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Backend bilan gaplashadigan yagona joy.
///
/// Bu yerda hech qanday `Either` yo'q — xatolik bo'lsa exception otiladi.
/// Uni `Failure` ga aylantirish repository'ning vazifasi.
abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
    String? timezone,
  });

  Future<AuthTokenModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getMe();

  Future<UserModel> updateMe({String? fullName, String? timezone});

  /// Shu qurilma sessiyasini serverда bekor qiladi. Auth header shart emas —
  /// access token allaqачон eskirgan bo'lsa ham chiqish ishlashi kerak.
  Future<void> logout(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? fullName,
    String? timezone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          // `null` maydonlarni umuman yubormaymiz — server default qo'yadi.
          'full_name': ?fullName,
          'timezone': ?timezone,
        },
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthTokenModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> updateMe({String? fullName, String? timezone}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.me,
        data: {'full_name': ?fullName, 'timezone': ?timezone},
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<void>(
        ApiConstants.logout,
        data: {'refresh_token': refreshToken},
      );
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
