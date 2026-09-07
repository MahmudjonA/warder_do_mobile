import '../../../../core/utils/api_date.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/repeat_rule.dart';

/// `repeat_rule` JSON ↔ [RepeatRule] o'girish.
///
/// Alohida ajratilgan, chunki u habit, shablon va yaratish so'rovida —
/// uch joyda ishlatiladi.
class RepeatRuleMapper {
  const RepeatRuleMapper._();

  static RepeatRule fromJson(Map<String, dynamic>? json) {
    switch (json?['type']) {
      case 'weekly':
        final days =
            (json?['days'] as List?)?.map((e) => (e as num).toInt()).toList() ??
            const <int>[];
        return WeeklyRepeat(days);
      case 'interval':
        return IntervalRepeat((json?['every_n_days'] as num?)?.toInt() ?? 1);
      default:
        // Noma'lum tur kelsa ilova qulamasligi uchun — har kuni.
        return const DailyRepeat();
    }
  }

  static Map<String, dynamic> toJson(RepeatRule rule) => switch (rule) {
    DailyRepeat() => {'type': 'daily'},
    WeeklyRepeat(:final days) => {'type': 'weekly', 'days': days},
    IntervalRepeat(:final everyNDays) => {
      'type': 'interval',
      'every_n_days': everyNDays,
    },
  };
}

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.title,
    required super.icon,
    required super.color,
    required super.type,
    required super.repeatRule,
    required super.order,
    required super.isArchived,
    required super.createdAt,
    super.groupId,
    super.description,
    super.goalValue,
    super.goalUnit,
    super.goalType,
    super.reminders,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'check',
      color: json['color'] as String? ?? '#6C7BF5',
      type: HabitType.fromJson(json['type'] as String?),
      description: json['description'] as String?,
      goalValue: (json['goal_value'] as num?)?.toDouble(),
      goalUnit: json['goal_unit'] as String?,
      goalType: GoalType.fromJson(json['goal_type'] as String?),
      repeatRule: RepeatRuleMapper.fromJson(
        json['repeat_rule'] as Map<String, dynamic>?,
      ),
      reminders:
          (json['reminders'] as List?)
              ?.map((e) => Reminder.parse((e as Map)['time'] as String))
              .toList() ??
          const [],
      order: (json['order'] as num?)?.toInt() ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// `POST /habits` uchun. Server generatsiya qiladigan maydonlar yuborilmaydi.
  ///
  /// `goal_value` bo'lmasa `goal_unit`/`goal_type` ham yuborilmaydi — aks
  /// holda server `422` qaytaradi.
  static Map<String, dynamic> toCreateJson(Habit habit) {
    final hasGoal = habit.goalValue != null;

    return {
      'group_id': habit.groupId,
      'title': habit.title,
      'icon': habit.icon,
      'color': habit.color,
      'type': habit.type.json,
      'description': habit.description,
      'goal_value': habit.goalValue,
      if (hasGoal) 'goal_unit': habit.goalUnit,
      if (hasGoal) 'goal_type': (habit.goalType ?? GoalType.atLeast).json,
      'repeat_rule': RepeatRuleMapper.toJson(habit.repeatRule),
      'reminders': habit.reminders.map((r) => {'time': r.json}).toList(),
    };
  }

  /// `PATCH /habits/{id}` uchun — faqat o'zgargan maydonlar.
  ///
  /// `clearGoal: true` bo'lsa `goal_value: null` yuboriladi; server unda
  /// `goal_unit` va `goal_type` ni ham o'zi tozalaydi.
  static Map<String, dynamic> toUpdateJson({
    String? title,
    String? icon,
    String? color,
    HabitType? type,
    String? description,
    double? goalValue,
    String? goalUnit,
    GoalType? goalType,
    RepeatRule? repeatRule,
    List<Reminder>? reminders,
    String? groupId,
    bool clearGroup = false,
    bool clearGoal = false,
  }) {
    return {
      'title': ?title,
      'icon': ?icon,
      'color': ?color,
      if (type != null) 'type': type.json,
      'description': ?description,
      if (clearGoal) 'goal_value': null else 'goal_value': ?goalValue,
      if (!clearGoal) 'goal_unit': ?goalUnit,
      if (!clearGoal && goalType != null) 'goal_type': goalType.json,
      if (repeatRule != null)
        'repeat_rule': RepeatRuleMapper.toJson(repeatRule),
      if (reminders != null)
        'reminders': reminders.map((r) => {'time': r.json}).toList(),
      if (clearGroup) 'group_id': null else 'group_id': ?groupId,
    };
  }

  /// Reorder so'rovi — body **massiv**, obyekt emas.
  static List<Map<String, dynamic>> toReorderJson(List<String> orderedIds) => [
    for (var i = 0; i < orderedIds.length; i++)
      {'id': orderedIds[i], 'order': i},
  ];

  static String formatDate(DateTime date) => ApiDate.format(date);
}
