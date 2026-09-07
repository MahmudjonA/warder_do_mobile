import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../entities/habit_template.dart';

/// Statistika, yutuqlar va ta'tillar.
abstract class ProgressRepository {
  Future<Either<Failure, StatsOverview>> getOverview();
  Future<Either<Failure, List<Achievement>>> getAchievements();

  Future<Either<Failure, List<Vacation>>> getVacations();

  Future<Either<Failure, Vacation>> createVacation({
    required DateTime startDate,
    required DateTime endDate,

    /// `null` — barcha odatlarga tegishli.
    List<String>? habitIds,
  });

  /// Diqqat: o'chirish o'sha kunlarni himoyasiz qoldiradi — streak
  /// qisqarishi mumkin. Foydalanuvchini ogohlantirish kerak.
  Future<Either<Failure, Unit>> deleteVacation(String id);
}
