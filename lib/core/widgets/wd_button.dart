import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'wd_icon.dart';

/// Ekranning asosiy harakati — screenshotlardagi pastdagi keng "pill" tugma.
///
/// [isLoading] holatida matn o'rniga spinner chiqadi va tugma bosilmaydi,
/// lekin balandligi o'zgarmaydi — layout sakramaydi.
class WdPrimaryButton extends StatelessWidget {
  const WdPrimaryButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;

  static const double height = 58;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final background = color ?? AppColors.primary;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: background.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: background,
            disabledBackgroundColor: background.withValues(alpha: 0.35),
            foregroundColor: AppColors.textOnPrimary,
            disabledForegroundColor: AppColors.textOnPrimary.withValues(
              alpha: 0.6,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.textOnPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Ikkilamchi harakat: fon yo'q, faqat matn (masalan "Ro'yxatdan o'tish").
class WdTextLink extends StatelessWidget {
  const WdTextLink({
    required this.prefix,
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Havoladan oldingi kulrang matn: "Hisobingiz yo'qmi? ".
  final String prefix;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        minimumSize: const Size(0, 44), // tegish maydoni kamida 44px
      ),
      child: Text.rich(
        TextSpan(
          text: prefix,
          style: AppTextStyles.caption.copyWith(fontSize: 15),
          children: [
            TextSpan(
              text: label,
              style: AppTextStyles.caption.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yumaloq qora orqaga qaytish tugmasi (screenshotlardagi chap yuqoridagi).
class WdCircleBackButton extends StatelessWidget {
  const WdCircleBackButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 44,
      child: Material(
        color: AppColors.surfaceHigh,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).maybePop(),
          child: const WdIcon(
            AppIcons.chevronLeft,
            size: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
