import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/stats_entities.dart';

/// Statistika ekrani uchun ma'lumot: kalendar, rekordlar, haftalik jadval.
abstract class StatsRepository {
  Future<Either<Failure, List<CalendarDay>>> getCalendar({
    required DateTime from,
    required DateTime to,
    String? habitId,
  });

  Future<Either<Failure, StatsRecords>> getRecords({
    required DateTime from,
    required DateTime to,
    String? habitId,
  });

  Future<Either<Failure, WeeklyStats>> getWeekly({
    required DateTime from,
    required DateTime to,
  });
}
