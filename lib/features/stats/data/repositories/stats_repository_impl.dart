import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stats_entities.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_remote_data_source.dart';

class StatsRepositoryImpl implements StatsRepository {
  const StatsRepositoryImpl(this._remote);

  final StatsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<CalendarDay>>> getCalendar({
    required DateTime from,
    required DateTime to,
    String? habitId,
  }) {
    return guardApi(
      () => _remote.getCalendar(from: from, to: to, habitId: habitId),
    );
  }

  @override
  Future<Either<Failure, StatsRecords>> getRecords({
    required DateTime from,
    required DateTime to,
    String? habitId,
  }) {
    return guardApi(
      () => _remote.getRecords(from: from, to: to, habitId: habitId),
    );
  }

  @override
  Future<Either<Failure, WeeklyStats>> getWeekly({
    required DateTime from,
    required DateTime to,
  }) {
    return guardApi(() => _remote.getWeekly(from: from, to: to));
  }
}
