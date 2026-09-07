/// Backend sanalarni faqat `"YYYY-MM-DD"` ko'rinishida qabul qiladi.
///
/// `DateTime.toIso8601String()` **yaramaydi** — u vaqt va timezone ham
/// qo'shib yuboradi, natijada server kunni noto'g'ri o'qiydi.
class ApiDate {
  const ApiDate._();

  static String format(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Serverdan kelgan `"2026-09-03"` ni **lokal** `DateTime` ga o'giradi.
  ///
  /// `DateTime.parse` UTC yarim tunni qaytaradi va lokal vaqtga o'tkazilganda
  /// kun siljib ketishi mumkin — shuning uchun qo'lda yig'amiz.
  static DateTime parse(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Vaqt qismini olib tashlaydi — sanalarni solishtirish uchun.
  static DateTime dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  /// Bugungi kundan keyingi (hali kelmagan) sanami?
  static bool isFuture(DateTime date) =>
      dayOnly(date).isAfter(dayOnly(DateTime.now()));
}
