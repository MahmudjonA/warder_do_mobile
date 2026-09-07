import 'package:flutter/material.dart';

/// WarderDo rang palitrasi.
///
/// Dizayn tili: sof qora fon, ustida ozgina ochiq "kartalar", bitta yorqin
/// periwinkle-binafsha primary rang va odatlar uchun to'yingan aksent ranglar.
class AppColors {
  const AppColors._();

  // --- Fon va yuzalar ---
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceHigh = Color(0xFF2C2C2E);
  static const Color surfaceInput = Color(0xFF161618);
  static const Color divider = Color(0xFF2C2C2E);

  // --- Brend ---
  static const Color primary = Color(0xFF6C63F0);
  static const Color primaryPressed = Color(0xFF5A51DE);
  static const Color primarySoft = Color(0x336C63F0);
  static const Color accentPink = Color(0xFFE94FCB);

  // --- Matn ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF636366);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // --- Holat ---
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFF0596A);
  static const Color warning = Color(0xFFE3C13F);

  /// Odat kartalari uchun aksentlar (screenshotlardagi ranglar).
  static const List<Color> habitPalette = [
    Color(0xFFF0596A), // qizil
    Color(0xFF3FD5C0), // teal
    Color(0xFF3B9BF0), // ko'k
    Color(0xFFE3C13F), // sariq
    Color(0xFFA855F7), // binafsha
    Color(0xFFE88B3C), // to'q sariq
    Color(0xFF46C55A), // yashil
    Color(0xFFE94FCB), // pushti
  ];

  /// Fonda ishlatiladigan yumshoq gradient (welcome ekrani).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63F0), Color(0xFFE94FCB)],
  );
}
