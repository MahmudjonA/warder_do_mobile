import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../error/exceptions.dart';

/// Token va cache uchun kalit-qiymat saqlash abstraksiyasi.
///
/// Abstraksiya bo'lishining sababi: testlarda in-memory implementatsiya
/// beramiz, data qatlami esa `flutter_secure_storage` haqida bilmaydi.
abstract class TokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Real implementatsiya: Android'da EncryptedSharedPreferences,
/// iOS'da Keychain. Token'ni `SharedPreferences`ga ochiq yozish mumkin emas.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  /// v11 default'i allaqachon AES-GCM + Keystore — qo'shimcha sozlama shart emas.
  static const AndroidOptions androidOptions = AndroidOptions();

  static const IOSOptions iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: androidOptions,
        iOptions: iosOptions,
      );
    } on Exception catch (e) {
      throw CacheException(
        'Saqlangan ma\u2019lumotni o\u2019qib bo\u2019lmadi: $e',
      );
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: androidOptions,
        iOptions: iosOptions,
      );
    } on Exception catch (e) {
      throw CacheException('Ma\u2019lumotni saqlab bo\u2019lmadi: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: androidOptions,
        iOptions: iosOptions,
      );
    } on Exception catch (_) {
      // O'chirish muvaffaqiyatsiz bo'lsa ham oqimni to'xtatmaymiz.
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll(aOptions: androidOptions, iOptions: iosOptions);
    } on Exception catch (_) {
      // Yuqoridagi kabi.
    }
  }
}

/// Testlar va web-preview uchun oddiy xotira implementatsiyasi.
class InMemoryTokenStorage implements TokenStorage {
  final Map<String, String> _map = {};

  @override
  Future<void> clear() async => _map.clear();

  @override
  Future<void> delete(String key) async => _map.remove(key);

  @override
  Future<String?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String value) async => _map[key] = value;
}
