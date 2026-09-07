import 'package:equatable/equatable.dart';

/// Odat qaysi kunlarda takrorlanishi.
///
/// Backend uni uch xil shaklda yuboradi:
/// ```json
/// {"type": "daily"}
/// {"type": "weekly", "days": [1, 3, 5]}
/// {"type": "interval", "every_n_days": 2}
/// ```
///
/// `sealed` — shuning uchun `switch` da barcha holatlarni qamrab olganingizni
/// kompilyator o'zi tekshiradi.
sealed class RepeatRule extends Equatable {
  const RepeatRule();

  /// Shu qoida bo'yicha [date] kuni odat bajarilishi kerakmi.
  ///
  /// Bosh ekran uchun server o'zi filtrlaydi; bu metod lokal tekshiruv
  /// (masalan optimistik yangilash yoki tahrirlash ekranidagi ko'rsatkich) uchun.
  bool occursOn(DateTime date, {required DateTime startedAt});

  @override
  List<Object?> get props => [];
}

/// Har kuni.
class DailyRepeat extends RepeatRule {
  const DailyRepeat();

  @override
  bool occursOn(DateTime date, {required DateTime startedAt}) => true;
}

/// Hafta kunlari bo'yicha. `1 = Dushanba … 7 = Yakshanba` —
/// Dart'dagi `DateTime.weekday` bilan aynan bir xil, konvertatsiya shart emas.
class WeeklyRepeat extends RepeatRule {
  const WeeklyRepeat(this.days);

  final List<int> days;

  @override
  bool occursOn(DateTime date, {required DateTime startedAt}) =>
      days.contains(date.weekday);

  @override
  List<Object?> get props => [days];
}

/// N kunda bir. Sanoq odat yaratilgan kundan boshlanadi.
class IntervalRepeat extends RepeatRule {
  const IntervalRepeat(this.everyNDays);

  final int everyNDays;

  @override
  bool occursOn(DateTime date, {required DateTime startedAt}) {
    if (everyNDays <= 0) return false;

    final from = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final to = DateTime(date.year, date.month, date.day);
    final diff = to.difference(from).inDays;

    if (diff < 0) return false;
    return diff % everyNDays == 0;
  }

  @override
  List<Object?> get props => [everyNDays];
}
