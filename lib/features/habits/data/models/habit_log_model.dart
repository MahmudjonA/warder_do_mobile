import '../../../../core/utils/api_date.dart';
import '../../../programs/data/models/program_models.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/daily_habit.dart';
import '../../domain/entities/habit_log.dart';
import 'achievement_model.dart';
import 'habit_model.dart';

class HabitLogModel extends HabitLog {
  const HabitLogModel({
    required super.id,
    required super.habitId,
    required super.date,
    required super.completed,
    super.value,
    super.durationSeconds,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      date: ApiDate.parse(json['date'] as String),
      value: (json['value'] as num?)?.toDouble(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      completed: json['completed'] as bool? ?? false,
    );
  }

  /// `POST /habits/{id}/logs` body.
  ///
  /// **Jami emas, qo'shiladigan miqdor yuboriladi.** "+0,5 L" bosilganda
  /// `{"value": 0.5}` — server o'zi mavjud qiymatga qo'shadi.
  static Map<String, dynamic> toLogJson({
    required DateTime date,
    double? value,
    int? durationSeconds,
    bool? completed,
  }) {
    return {
      'date': ApiDate.format(date),
      'value': ?value,
      'duration_seconds': ?durationSeconds,
      'completed': ?completed,
    };
  }
}

/// `GET /habits?date=...` javobining bitta elementi.
///
/// Server odat maydonlarini, `date` ni va `log` ni **bitta obyektda**
/// qaytaradi — shuning uchun bosh ekran uchun bitta so'rov yetarli.
class DailyHabitModel extends DailyHabit {
  const DailyHabitModel({
    required super.habit,
    required super.date,
    super.log,
    super.programDay,
  });

  factory DailyHabitModel.fromJson(Map<String, dynamic> json) {
    final rawLog = json['log'];
    final rawProgramDay = json['program_day'];

    return DailyHabitModel(
      habit: HabitModel.fromJson(json),
      // `date` bo'lmasa (masalan `GET /habits/{id}` javobida) — bugun.
      date: json['date'] == null
          ? ApiDate.dayOnly(DateTime.now())
          : ApiDate.parse(json['date'] as String),
      log: rawLog == null
          ? null
          : HabitLogModel.fromJson(rawLog as Map<String, dynamic>),
      // Dastur odatida server o'sha kunning yuklamasini (`target`) va izohini
      // (`note`) qo'shib yuboradi — kartani bosganda ko'rsatamiz.
      programDay: rawProgramDay == null
          ? null
          : ProgramDayModel.fromJson(rawProgramDay as Map<String, dynamic>),
    );
  }
}

/// `POST /habits/{id}/logs` javobi: `{log, newly_unlocked}`.
class LogResultModel extends LogResult {
  const LogResultModel({required super.log, required super.newlyUnlocked});

  factory LogResultModel.fromJson(Map<String, dynamic> json) {
    return LogResultModel(
      log: HabitLogModel.fromJson(json['log'] as Map<String, dynamic>),
      newlyUnlocked:
          (json['newly_unlocked'] as List?)
              ?.map((e) => AchievementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Achievement>[],
    );
  }
}

/// `GET /habits/{id}/streak` javobi: `{current, longest}`.
class StreakInfoModel extends StreakInfo {
  const StreakInfoModel({required super.current, required super.longest});

  factory StreakInfoModel.fromJson(Map<String, dynamic> json) {
    return StreakInfoModel(
      current: (json['current'] as num?)?.toInt() ?? 0,
      longest: (json['longest'] as num?)?.toInt() ?? 0,
    );
  }
}
