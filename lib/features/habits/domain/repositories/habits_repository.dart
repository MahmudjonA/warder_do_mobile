import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/achievement.dart';
import '../entities/daily_habit.dart';
import '../entities/habit.dart';
import '../entities/habit_log.dart';
import '../entities/habit_template.dart';

/// Odatlar bo'yicha domain kontrakti.
///
/// Domain qatlami faqat shu interfeysni biladi — Dio, JSON va HTTP status
/// kodlari `data` qatlamida qoladi.
abstract class HabitsRepository {
  /// Bosh ekran uchun: [date] kuniga tegishli odatlar + o'sha kungi loglar.
  ///
  /// [all] `true` bo'lsa jadvalga qaramay hammasi qaytadi (sozlamalar ekrani).
  Future<Either<Failure, List<DailyHabit>>> getDailyHabits({
    DateTime? date,
    bool all = false,
    bool includeArchived = false,
  });

  Future<Either<Failure, Habit>> getHabit(String id);
  Future<Either<Failure, Habit>> createHabit(Habit habit);
  Future<Either<Failure, Habit>> updateHabit(
    String id,
    Map<String, dynamic> changes,
  );

  /// **Hard delete** — odat va butun tarixi o'chadi. Qaytarib bo'lmaydi.
  Future<Either<Failure, Unit>> deleteHabit(String id);

  /// O'chirishga muqobil: ro'yxatdan yo'qoladi, lekin loglar saqlanadi.
  Future<Either<Failure, Habit>> archiveHabit(String id);
  Future<Either<Failure, Habit>> unarchiveHabit(String id);

  Future<Either<Failure, List<Habit>>> reorderHabits(List<String> orderedIds);

  /// Kunlik progress qo'shadi.
  ///
  /// **Jami emas, qo'shiladigan miqdor yuboriladi**: "+0,5 L" bosilganda
  /// `value: 0.5`. Server mavjud qiymatga qo'shadi va `completed` ni o'zi
  /// hisoblaydi.
  Future<Either<Failure, LogResult>> logHabit(
    String habitId, {
    required DateTime date,
    double? value,
    int? durationSeconds,
    bool? completed,
  });

  /// Belgini olib tashlaydi. Idempotent — bo'sh kunda ham xato bermaydi.
  Future<Either<Failure, Unit>> unlogHabit(String habitId, DateTime date);

  Future<Either<Failure, List<HabitLog>>> getLogs(
    String habitId, {
    DateTime? from,
    DateTime? to,
  });

  Future<Either<Failure, StreakInfo>> getStreak(String habitId);

  /// Tayyor shablonlar. Auth talab qilmaydi.
  Future<Either<Failure, List<HabitTemplate>>> getTemplates({String? category});
}
