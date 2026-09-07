import '../../../../core/utils/api_date.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_template.dart';
import 'habit_model.dart';

class AchievementModel extends Achievement {
  const AchievementModel({
    required super.type,
    required super.title,
    required super.description,
    required super.category,
    required super.threshold,
    required super.progress,
    required super.progressPercent,
    required super.unlocked,
    super.unlockedAt,
    super.habitId,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'streak',
      threshold: (json['threshold'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progress_percent'] as num?)?.toInt() ?? 0,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] == null
          ? null
          : DateTime.parse(json['unlocked_at'] as String).toLocal(),
      habitId: json['habit_id'] as String?,
    );
  }
}

class HabitTemplateModel extends HabitTemplate {
  const HabitTemplateModel({
    required super.key,
    required super.category,
    required super.title,
    required super.icon,
    required super.color,
    required super.type,
    required super.repeatRule,
    super.goalValue,
    super.goalUnit,
    super.goalType,
  });

  factory HabitTemplateModel.fromJson(Map<String, dynamic> json) {
    return HabitTemplateModel(
      key: json['key'] as String? ?? '',
      category: json['category'] as String? ?? 'good',
      title: json['title'] as String? ?? '',
      icon: json['icon'] as String? ?? 'check',
      color: json['color'] as String? ?? '#6C7BF5',
      type: HabitType.fromJson(json['type'] as String?),
      goalValue: (json['goal_value'] as num?)?.toDouble(),
      goalUnit: json['goal_unit'] as String?,
      goalType: GoalType.fromJson(json['goal_type'] as String?),
      repeatRule: RepeatRuleMapper.fromJson(
        json['repeat_rule'] as Map<String, dynamic>?,
      ),
    );
  }
}

class StatsOverviewModel extends StatsOverview {
  const StatsOverviewModel({
    required super.date,
    required super.dueToday,
    required super.completedToday,
    required super.todayProgressPercent,
    required super.longestStreak,
    required super.totalCompleted,
    required super.activeHabits,
    required super.onVacation,
    super.longestStreakHabitId,
    super.longestStreakHabitTitle,
  });

  factory StatsOverviewModel.fromJson(Map<String, dynamic> json) {
    final streakHabit = json['longest_streak_habit'] as Map<String, dynamic>?;

    return StatsOverviewModel(
      date: ApiDate.parse(json['date'] as String),
      dueToday: (json['due_today'] as num?)?.toInt() ?? 0,
      completedToday: (json['completed_today'] as num?)?.toInt() ?? 0,
      todayProgressPercent:
          (json['today_progress_percent'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      longestStreakHabitId: streakHabit?['habit_id'] as String?,
      longestStreakHabitTitle: streakHabit?['title'] as String?,
      totalCompleted: (json['total_completed'] as num?)?.toInt() ?? 0,
      activeHabits: (json['active_habits'] as num?)?.toInt() ?? 0,
      onVacation: json['on_vacation'] as bool? ?? false,
    );
  }
}

class VacationModel extends Vacation {
  const VacationModel({
    required super.id,
    required super.startDate,
    required super.endDate,
    super.habitIds,
  });

  factory VacationModel.fromJson(Map<String, dynamic> json) {
    return VacationModel(
      id: json['id'] as String,
      startDate: ApiDate.parse(json['start_date'] as String),
      endDate: ApiDate.parse(json['end_date'] as String),
      habitIds: (json['habit_ids'] as List?)?.map((e) => e as String).toList(),
    );
  }

  static Map<String, dynamic> toCreateJson({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? habitIds,
  }) {
    return {
      'start_date': ApiDate.format(startDate),
      'end_date': ApiDate.format(endDate),
      // `null` — barcha odatlarga tegishli degani, shuning uchun ataylab
      // yuboriladi (tashlab ketilmaydi).
      'habit_ids': habitIds,
    };
  }
}
