import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Saqlangan sessiya tekshirilayotgan paytdagi ekran.
///
/// `AuthStatus.unknown` holatida ko'rsatiladi. Bu bosqich bo'lmasa,
/// token amal qilayotgan bo'lsa ham login ekrani bir lahza ko'rinib ketardi.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Logo(size: 76),
            SizedBox(height: 24),
            Text(AppStrings.appName, style: AppTextStyles.title),
            SizedBox(height: 28),
            SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ],
        ),
      ),
    );
  }
}

/// WarderDo logotipi — `assets/logo.png`.
class _Logo extends StatelessWidget {
  const _Logo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      height: size,
      width: size,
      fit: BoxFit.contain,
    );
  }
}
