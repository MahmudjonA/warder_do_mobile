import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/achievement_model.dart';

/// Statistika, yutuqlar va ta'tillar — bosh ekrandan tashqaridagi ma'lumotlar.
abstract class ProgressRemoteDataSource {
  Future<StatsOverviewModel> getOverview();

  /// Butun katalog qaytadi: ochilgani ham, ochilmagani ham, progress bilan.
  Future<List<AchievementModel>> getAchievements();

  Future<List<VacationModel>> getVacations();

  Future<VacationModel> createVacation({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? habitIds,
  });

  Future<void> deleteVacation(String id);
}

class ProgressRemoteDataSourceImpl implements ProgressRemoteDataSource {
  const ProgressRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<StatsOverviewModel> getOverview() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.statsOverview,
      );
      return StatsOverviewModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiConstants.achievements);
      return response.data!
          .map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<List<VacationModel>> getVacations() async {
    try {
      final response = await _dio.get<List<dynamic>>(ApiConstants.vacations);
      return response.data!
          .map((e) => VacationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<VacationModel> createVacation({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? habitIds,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.vacations,
        data: VacationModel.toCreateJson(
          startDate: startDate,
          endDate: endDate,
          habitIds: habitIds,
        ),
      );
      return VacationModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteVacation(String id) async {
    try {
      // Diqqat: bu o'sha kunlarni himoyasiz qoldiradi — streak qisqarishi mumkin.
      await _dio.delete<void>(ApiConstants.vacation(id));
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
