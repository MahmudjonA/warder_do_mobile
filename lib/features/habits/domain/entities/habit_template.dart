import 'package:equatable/equatable.dart';

import 'habit.dart';
import 'repeat_rule.dart';

/// `GET /templates` — tayyor odat shablonlari. **Auth kerak emas.**
///
/// Shablon tanlanganda uning maydonlari formaga ko'chiriladi, foydalanuvchi
/// tahrirlaydi, keyin `POST /habits` qilinadi. [key] backendga yuborilmaydi —
/// u faqat ilova ichida shablonni ajratish uchun.
class HabitTemplate extends Equatable {
  const HabitTemplate({
    required this.key,
    required this.category,
    required this.title,
    required this.icon,
    required this.color,
    required this.type,
    required this.repeatRule,
    this.goalValue,
    this.goalUnit,
    this.goalType,
  });

  final String key;

  /// `"good"`, `"health"`, `"bad"` yoki `"task"`.
  final String category;

  final String title;
  final String icon;
  final String color;
  final HabitType type;
  final double? goalValue;
  final String? goalUnit;
  final GoalType? goalType;
  final RepeatRule repeatRule;

  @override
  List<Object?> get props => [
    key,
    category,
    title,
    icon,
    color,
    type,
    goalValue,
    goalUnit,
    goalType,
    repeatRule,
  ];
}

/// Shablonlar ekranidagi bitta bo'lim («Утро», «Здоровье и спорт»...).
///
/// Guruh shablonlaridagi [GroupTemplateSection] bilan bir xil g'oya:
/// katalog client tomonda, shuning uchun bo'limlar ham shu yerda.
class HabitTemplateSection extends Equatable {
  const HabitTemplateSection({required this.title, required this.templates});

  final String title;
  final List<HabitTemplate> templates;

  @override
  List<Object?> get props => [title, templates];
}

/// `GET /stats/overview` — bosh ekran / dashboard uchun.
class StatsOverview extends Equatable {
  const StatsOverview({
    required this.date,
    required this.dueToday,
    required this.completedToday,
    required this.todayProgressPercent,
    required this.longestStreak,
    required this.totalCompleted,
    required this.activeHabits,
    required this.onVacation,
    this.longestStreakHabitId,
    this.longestStreakHabitTitle,
  });

  /// Server hisoblagan "bugun" — foydalanuvchining timezone'ida.
  final DateTime date;

  final int dueToday;
  final int completedToday;

  /// 0–100. Bugun hech nima kerak bo'lmasa **100**, 0 emas.
  final int todayProgressPercent;

  final int longestStreak;
  final String? longestStreakHabitId;
  final String? longestStreakHabitTitle;

  final int totalCompleted;
  final int activeHabits;

  /// Hozir ta'tilda bo'lsa `true` — bosh ekranda belgi ko'rsatish uchun.
  final bool onVacation;

  @override
  List<Object?> get props => [
    date,
    dueToday,
    completedToday,
    todayProgressPercent,
    longestStreak,
    longestStreakHabitId,
    longestStreakHabitTitle,
    totalCompleted,
    activeHabits,
    onVacation,
  ];
}

/// Ta'til: bu kunlarda bajarilmagan odat streakni **buzmaydi**.
///
/// Lekin uzaytirmaydi ham: 5 kunlik streak + 10 kun ta'til + 1 kun bajarish = 6.
class Vacation extends Equatable {
  const Vacation({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.habitIds,
  });

  final String id;
  final DateTime startDate;
  final DateTime endDate;

  /// `null` — barcha odatlarga tegishli.
  final List<String>? habitIds;

  bool covers(DateTime date) =>
      !date.isBefore(startDate) && !date.isAfter(endDate);

  @override
  List<Object?> get props => [id, startDate, endDate, habitIds];
}
