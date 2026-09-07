import '../../domain/entities/user.dart';

/// `UserRead` javobining Dart ko'rinishi.
///
/// Entity'dan meros oladi, ya'ni domain qatlami uchun bu oddiy [User].
/// JSON bilan ishlash faqat shu klassda qoladi.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.isActive,
    required super.timezone,
    required super.createdAt,
    super.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      timezone: json['timezone'] as String? ?? 'UTC',
      // Server UTC yuboradi. `toUtc()` — server "Z" qo'ymay qolgan holatga
      // qarshi himoya, aks holda lokal vaqt deb o'qilib qolardi.
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    );
  }

  /// Faqat lokal cache uchun. Serverga hech qachon yuborilmaydi.
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'is_active': isActive,
    'timezone': timezone,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    fullName: user.fullName,
    isActive: user.isActive,
    timezone: user.timezone,
    createdAt: user.createdAt,
  );
}
