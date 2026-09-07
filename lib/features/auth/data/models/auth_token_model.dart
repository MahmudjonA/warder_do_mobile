import '../../domain/entities/auth_token.dart';

/// `/auth/login` va `/auth/refresh` javobi:
/// `{access_token, token_type, expires_in, refresh_token, refresh_expires_in}`.
class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.tokenType,
    required super.expiresAt,
    required super.refreshToken,
    required super.refreshExpiresAt,
  });

  /// [receivedAt] — javob kelgan payt. Testda vaqtni qotirish uchun beriladi.
  factory AuthTokenModel.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) {
    final now = (receivedAt ?? DateTime.now()).toUtc();
    // Server muddatlarni **sekundlarda** beradi.
    final accessSeconds = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final refreshSeconds =
        (json['refresh_expires_in'] as num?)?.toInt() ?? 2592000;

    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresAt: now.add(Duration(seconds: accessSeconds)),
      refreshToken: json['refresh_token'] as String? ?? '',
      refreshExpiresAt: now.add(Duration(seconds: refreshSeconds)),
    );
  }

  factory AuthTokenModel.fromStorage({
    required String accessToken,
    required String tokenType,
    required String expiresAtIso,
    required String refreshToken,
    required String refreshExpiresAtIso,
  }) {
    return AuthTokenModel(
      accessToken: accessToken,
      tokenType: tokenType,
      expiresAt: DateTime.parse(expiresAtIso).toUtc(),
      refreshToken: refreshToken,
      refreshExpiresAt: DateTime.parse(refreshExpiresAtIso).toUtc(),
    );
  }

  String get expiresAtIso => expiresAt.toIso8601String();
  String get refreshExpiresAtIso => refreshExpiresAt.toIso8601String();
}
