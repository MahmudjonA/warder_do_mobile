import '../../../../core/utils/api_date.dart';
import '../../domain/entities/stats_entities.dart';

/// `GET /stats/calendar` javobining bitta elementini o'qiydi.
class CalendarDayModel extends CalendarDay {
  const CalendarDayModel({
    required super.date,
    required super.status,
    required super.due,
    required super.completed,
    required super.progressPercent,
  });

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayModel(
      date: ApiDate.parse(json['date'] as String),
      status: DayStatus.fromJson(json['status'] as String?),
      due: (json['due'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
    );
  }
}

class StatsRecordsModel extends StatsRecords {
  const StatsRecordsModel({
    required super.fromDate,
    required super.toDate,
    required super.currentStreak,
    required super.longestStreak,
    required super.completed,
    required super.due,
    required super.successRate,
  });

  factory StatsRecordsModel.fromJson(Map<String, dynamic> json) {
    return StatsRecordsModel(
      fromDate: ApiDate.parse(json['from_date'] as String),
      toDate: ApiDate.parse(json['to_date'] as String),
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      completed: (json['completed'] as num?)?.toInt() ?? 0,
      due: (json['due'] as num?)?.toInt() ?? 0,
      successRate: (json['success_rate'] as num?)?.toInt() ?? 0,
    );
  }
}

class WeeklyStatsModel extends WeeklyStats {
  const WeeklyStatsModel({
    required super.fromDate,
    required super.toDate,
    required super.habits,
  });

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStatsModel(
      fromDate: ApiDate.parse(json['from_date'] as String),
      toDate: ApiDate.parse(json['to_date'] as String),
      habits: (json['habits'] as List<dynamic>? ?? const [])
          .map((e) => WeeklyHabitModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WeeklyHabitModel extends WeeklyHabit {
  const WeeklyHabitModel({
    required super.id,
    required super.title,
    required super.icon,
    required super.color,
    required super.days,
  });

  factory WeeklyHabitModel.fromJson(Map<String, dynamic> json) {
    return WeeklyHabitModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? 'check',
      color: json['color'] as String? ?? '#6C7BF5',
      days: (json['days'] as List<dynamic>? ?? const [])
          .map((e) => WeeklyDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class WeeklyDayModel extends WeeklyDay {
  const WeeklyDayModel({
    required super.date,
    required super.status,
    required super.progressPercent,
  });

  factory WeeklyDayModel.fromJson(Map<String, dynamic> json) {
    return WeeklyDayModel(
      date: ApiDate.parse(json['date'] as String),
      status: DayStatus.fromJson(json['status'] as String?),
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
    );
  }
}
