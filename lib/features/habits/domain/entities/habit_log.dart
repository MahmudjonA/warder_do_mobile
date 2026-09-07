import 'package:equatable/equatable.dart';

/// Bitta odat + bitta kun = bitta log.
///
/// Server takroriy so'rovda yangi yozuv yaratmaydi, mavjudiga **qo'shib
/// boradi**: `+0.5` uch marta yuborilsa `value` 1.5 bo'ladi.
class HabitLog extends Equatable {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.value,
    this.durationSeconds,
  });

  final String id;
  final String habitId;
  final DateTime date;

  /// Jami to'plangan miqdor (litr, sahifa...).
  final double? value;

  /// Timer odatlari uchun jami sekundlar.
  final int? durationSeconds;

  final bool completed;

  HabitLog copyWith({double? value, int? durationSeconds, bool? completed}) {
    return HabitLog(
      id: id,
      habitId: habitId,
      date: date,
      value: value ?? this.value,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    habitId,
    date,
    value,
    durationSeconds,
    completed,
  ];
}

/// `GET /habits/{id}/streak` javobi.
class StreakInfo extends Equatable {
  const StreakInfo({required this.current, required this.longest});

  /// Davom etayotgan seriya. Bugun hali bajarilmagan bo'lsa ham kamaymaydi —
  /// kun tugamagan.
  final int current;

  final int longest;

  static const StreakInfo empty = StreakInfo(current: 0, longest: 0);

  @override
  List<Object?> get props => [current, longest];
}
