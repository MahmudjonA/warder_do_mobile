import 'package:equatable/equatable.dart';

/// Foydalanuvchi — domain qatlamining sof obyekti.
///
/// Bu yerda JSON ham, Dio ham, Flutter ham yo'q. Shuning uchun uni
/// backend o'zgarganda ham, UI o'zgarganda ham qayta yozish shart emas.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.timezone,
    required this.createdAt,
    this.fullName,
  });

  /// UUID. JWT ichidagi `sub` claim shu qiymat.
  final String id;

  /// Har doim kichik harfda — backend registrni normallashtiradi.
  final String email;

  final String? fullName;

  /// `false` bo'lsa hisob bloklangan: server 403 qaytaradi.
  final bool isActive;

  /// IANA nomi, masalan `Asia/Tashkent`.
  ///
  /// Bu shunchaki ma'lumot emas: "bugun" qaysi kun ekanini, streak hisobini
  /// va statistikani aynan shu qiymat belgilaydi.
  final String timezone;

  final DateTime createdAt;

  /// UI'da ko'rsatish uchun ism: to'liq ism bo'lmasa email'ning boshi.
  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email.split('@').first;
  }

  /// Avatar o'rniga chiqadigan bosh harflar.
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    final name = displayName;
    return name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isActive,
    String? timezone,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    isActive,
    timezone,
    createdAt,
  ];
}
