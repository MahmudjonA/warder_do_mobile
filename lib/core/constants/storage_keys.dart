/// Secure storage kalitlari. Bitta joyda turgani uchun tasodifan
/// ikki xil kalit ishlatib yuborish ehtimoli yo'q.
class StorageKeys {
  const StorageKeys._();

  static const String accessToken = 'wd_access_token';
  static const String tokenType = 'wd_token_type';
  static const String tokenExpiresAt = 'wd_token_expires_at';
  static const String refreshToken = 'wd_refresh_token';
  static const String refreshExpiresAt = 'wd_refresh_expires_at';
  static const String cachedUser = 'wd_cached_user';
}
