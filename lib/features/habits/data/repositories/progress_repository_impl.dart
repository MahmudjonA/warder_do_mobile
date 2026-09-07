import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/habit_template.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_data_source.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl(this._remote);

  final ProgressRemoteDataSource _remote;

  @override
  Future<Either<Failure, StatsOverview>> getOverview() =>
      guardApi(() => _remote.getOverview());

  @override
  Future<Either<Failure, List<Achievement>>> getAchievements() =>
      guardApi(() => _remote.getAchievements());

  @override
  Future<Either<Failure, List<Vacation>>> getVacations() =>
      guardApi(() => _remote.getVacations());

  @override
  Future<Either<Failure, Vacation>> createVacation({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? habitIds,
  }) {
    return guardApi(
      () => _remote.createVacation(
        startDate: startDate,
        endDate: endDate,
        habitIds: habitIds,
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteVacation(String id) => guardApi(() async {
    await _remote.deleteVacation(id);
    return unit;
  });
}
