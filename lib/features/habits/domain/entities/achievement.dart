import 'package:equatable/equatable.dart';

import 'habit_log.dart';

/// Yutuq. `GET /achievements` **butun katalogni** qaytaradi —
/// ochilgani ham, ochilmagani ham, progress bilan birga.
class Achievement extends Equatable {
  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.threshold,
    required this.progress,
    required this.progressPercent,
    required this.unlocked,
    this.unlockedAt,
    this.habitId,
  });

  /// Barqaror kalit: `"streak_7"`, `"goal_100"`, `"timer_30min"`.
  ///
  /// [title] va [description] serverdan **ingliz tilida** keladi, shuning
  /// uchun UI da shu kalit bo'yicha o'zbekcha matn ko'rsatiladi — `type`
  /// hech qachon o'zgarmaydi.
  final String type;

  final String title;
  final String description;

  /// `"streak"`, `"goal"` yoki `"timer"`.
  final String category;

  final int threshold;
  final int progress;

  /// 0–100. To'g'ridan-to'g'ri progress ring uchun.
  final int progressPercent;

  final bool unlocked;
  final DateTime? unlockedAt;
  final String? habitId;

  @override
  List<Object?> get props => [
    type,
    title,
    description,
    category,
    threshold,
    progress,
    progressPercent,
    unlocked,
    unlockedAt,
    habitId,
  ];
}

/// `POST /habits/{id}/logs` javobi.
class LogResult extends Equatable {
  const LogResult({required this.log, required this.newlyUnlocked});

  /// Serverdagi yakuniy holat (qo'shilgandan **keyingi** jami).
  final HabitLog log;

  /// Bo'sh bo'lmasa — "Yangi yutuq!" oynasini ko'rsatish kerak.
  ///
  /// Faqat kun `completed` ga **o'tgan paytda** to'ladi, har "+0,5 L" da emas.
  final List<Achievement> newlyUnlocked;

  @override
  List<Object?> get props => [log, newlyUnlocked];
}
