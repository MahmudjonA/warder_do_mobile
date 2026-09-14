import 'package:equatable/equatable.dart';

/// Kun holati — uchala statistika endpointida bir xil ishlatiladi.
///
/// `rest` va `vacation` `missed` dan ataylab ajratilgan: ular rejaning bir
/// qismi, muvaffaqiyatsizlik emas — ekranda ham boshqacha ko'rsatiladi.
enum DayStatus {
  /// To'liq bajarilgan — to'ldirilgan doira.
  done,

  /// Boshlangan, lekin maqsadga yetmagan — faqat halqa.
  partial,

  /// Kerak edi, bajarilmadi, kun o'tdi — bo'sh.
  missed,

  /// Bugun kerak, hali bajarilmagan — halqa.
  pending,

  /// Rejalashtirilgan, lekin hali kelmagan — kulrang.
  future,

  /// O'sha kuni jadvalda yo'q edi — bo'sh.
  notDue,

  /// Dastur dam olish kuni — alohida belgi.
  rest,

  /// Ta'til bilan himoyalangan — alohida belgi.
  vacation;

  static DayStatus fromJson(String? value) => switch (value) {
    'done' => DayStatus.done,
    'partial' => DayStatus.partial,
    'missed' => DayStatus.missed,
    'pending' => DayStatus.pending,
    'future' => DayStatus.future,
    'rest' => DayStatus.rest,
    'vacation' => DayStatus.vacation,
    _ => DayStatus.notDue,
  };

  /// Ketma-ket `done` kunlarni chiziq bilan bog'lash uchun.
  bool get isDone => this == DayStatus.done;

  /// Reja bo'yicha "hech narsa kutilmagan" kun (success rate hisobiga kirmaydi).
  bool get isProtected => this == DayStatus.rest || this == DayStatus.vacation;
}

/// Statistika davri (Records bloki uchun).
enum RecordsPeriod {
  last7(7),
  last30(30),
  last90(90);

  const RecordsPeriod(this.days);

  final int days;
}

/// `GET /stats/calendar` — oraliqdagi bitta kun.
class CalendarDay extends Equatable {
  const CalendarDay({
    required this.date,
    required this.status,
    required this.due,
    required this.completed,
    required this.progressPercent,
  });

  final DateTime date;
  final DayStatus status;
  final int due;
  final int completed;

  /// 0–100. Halqani chizish uchun.
  final int progressPercent;

  @override
  List<Object?> get props => [date, status, due, completed, progressPercent];
}

/// `GET /stats/records` — 4 ta katta raqam.
class StatsRecords extends Equatable {
  const StatsRecords({
    required this.fromDate,
    required this.toDate,
    required this.currentStreak,
    required this.longestStreak,
    required this.completed,
    required this.due,
    required this.successRate,
  });

  final DateTime fromDate;
  final DateTime toDate;

  /// Streaklar davrga bog'liq emas — butun tarixdan hisoblanadi.
  final int currentStreak;
  final int longestStreak;

  final int completed;
  final int due;

  /// 0–100. `completed / due × 100` (ta'til/dam kunlarisiz).
  final int successRate;

  @override
  List<Object?> get props => [
    fromDate,
    toDate,
    currentStreak,
    longestStreak,
    completed,
    due,
    successRate,
  ];
}

/// `GET /stats/weekly` — odat × kun jadvali.
class WeeklyStats extends Equatable {
  const WeeklyStats({
    required this.fromDate,
    required this.toDate,
    required this.habits,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final List<WeeklyHabit> habits;

  @override
  List<Object?> get props => [fromDate, toDate, habits];
}

/// Haftalik jadvaldagi bitta qator: odat va uning 7 kuni.
class WeeklyHabit extends Equatable {
  const WeeklyHabit({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.days,
  });

  final String id;
  final String title;
  final String icon;
  final String color;

  /// `from` dan `to` gacha to'liq va tartibda — indeks bo'yicha ishlatsa bo'ladi.
  final List<WeeklyDay> days;

  @override
  List<Object?> get props => [id, title, icon, color, days];
}

class WeeklyDay extends Equatable {
  const WeeklyDay({
    required this.date,
    required this.status,
    required this.progressPercent,
  });

  final DateTime date;
  final DayStatus status;
  final int progressPercent;

  @override
  List<Object?> get props => [date, status, progressPercent];
}

/// "All Habits" tanlagichi uchun yengil ko'rinish — bosh ekrandagi to'liq
/// [Habit] emas, faqat ro'yxatga kerakli maydonlar.
class HabitOption extends Equatable {
  const HabitOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final String icon;
  final String color;

  @override
  List<Object?> get props => [id, title, icon, color];
}
