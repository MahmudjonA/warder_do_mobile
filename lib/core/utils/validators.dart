import 'dart:convert';

import '../constants/app_strings.dart';

/// Client tomondagi validatsiya — backenddagi qoidalarning aynan nusxasi.
///
/// Maqsad: keraksiz tarmoq so'rovini oldini olish. Server baribir o'zi
/// tekshiradi, bu yerdagi tekshiruv faqat UX uchun.
class Validators {
  const Validators._();

  static final RegExp _emailRegExp = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
    r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  /// Backend `EmailStr` ga mos keladigan minimal tekshiruv.
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.errEmailRequired;
    if (v.length > 320) return AppStrings.errEmailInvalid;
    if (!_emailRegExp.hasMatch(v)) return AppStrings.errEmailInvalid;
    return null;
  }

  /// Backenddagi qoidalar: 8..128 belgi va **72 baytdan** oshmasligi.
  ///
  /// 72 bayt cheklovi bcrypt'dan keladi: undan uzun parolni bcrypt jimgina
  /// kesib tashlaydi, shuning uchun server 422 qaytaradi. Kirill yoki emoji
  /// bitta belgi uchun bir necha bayt egallaydi — shu sabab tekshiruv
  /// `utf8.encode` natijasining uzunligi bo'yicha.
  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.errPasswordRequired;
    if (v.length < 8) return AppStrings.errPasswordShort;
    if (v.length > 128) return AppStrings.errPasswordLong;
    if (utf8.encode(v).length > 72) return AppStrings.errPasswordBytes;
    return null;
  }

  /// Login ekranida uzunlik tekshiruvi shart emas — faqat bo'shligini ko'ramiz,
  /// aks holda eski parolli foydalanuvchi kira olmay qolishi mumkin.
  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return AppStrings.errPasswordRequired;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '') != original) return AppStrings.errPasswordMismatch;
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null; // ixtiyoriy maydon
    if (v.length > 255) return AppStrings.errNameLong;
    return null;
  }
}
