import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Qurilmaning IANA timezone nomini oladi (masalan `Asia/Tashkent`).
///
/// Backend `timezone` maydonida **IANA nomini** kutadi — `DateTime.now()
/// .timeZoneName` esa platformaga qarab `+05` yoki `Uzbekistan Standard Time`
/// qaytaradi va server uni 422 bilan rad etadi. Shuning uchun alohida plugin.
class DeviceTimezone {
  const DeviceTimezone._();

  /// Server default'i bilan bir xil — plugin ishlamasa shu ketadi.
  static const String fallback = 'UTC';

  static String? _cached;

  /// Aniqlab bo'lmasa [fallback] qaytaradi: timezone tufayli ro'yxatdan
  /// o'tishni to'xtatib qo'yish mantiqsiz, uni keyin profildan tuzatish mumkin.
  static Future<String> resolve() async {
    if (_cached != null) return _cached!;
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final id = info.identifier;
      // IANA nomi doim `Region/City` ko'rinishida bo'ladi.
      _cached = id.contains('/') ? id : fallback;
    } on Exception catch (e) {
      debugPrint('DeviceTimezone: не удалось определить ($e), берём $fallback');
      _cached = fallback;
    }
    return _cached!;
  }

  /// Profil ekranidagi tanlov ro'yxati.
  static const List<String> common = [
    'Asia/Tashkent',
    'Asia/Samarkand',
    'Asia/Almaty',
    'Asia/Dubai',
    'Asia/Istanbul',
    'Europe/Moscow',
    'Europe/London',
    'Europe/Berlin',
    'America/New_York',
    'America/Los_Angeles',
    'UTC',
  ];
}
