import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/wd_button.dart';
import '../../../../core/widgets/wd_icon.dart';

/// Ilovaning birinchi ekrani: nima uchun kerakligini bir jumlada aytadi
/// va ikkita yo'l beradi — ro'yxatdan o'tish yoki kirish.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(AppStrings.welcomeTitle, style: AppTextStyles.display),
              const SizedBox(height: 14),
              Text(AppStrings.welcomeSubtitle, style: AppTextStyles.bodyMuted),
              const SizedBox(height: 36),

              // Ilova ichida nima kutayotganini ko'rsatuvchi namuna kartalar.
              const Expanded(child: _HabitPreviewStack()),

              WdPrimaryButton(
                label: AppStrings.getStarted,
                onPressed: () => context.push(AppRoutes.register),
              ),
              const SizedBox(height: 4),
              Center(
                child: WdTextLink(
                  prefix: AppStrings.haveAccount,
                  label: AppStrings.signIn,
                  onPressed: () => context.push(AppRoutes.login),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dekorativ blok: haqiqiy odat kartalariga o'xshash namunalar.
class _HabitPreviewStack extends StatelessWidget {
  const _HabitPreviewStack();

  static const List<
    ({String title, String subtitle, AppIconData icon, int color, int streak})
  >
  _samples = [
    (
      title: 'Читать книгу',
      subtitle: 'Каждый день, 20 страниц',
      icon: AppIcons.book,
      color: 4,
      streak: 12,
    ),
    (
      title: 'Пить воду',
      subtitle: 'Каждый день, 2 литра',
      icon: AppIcons.water,
      color: 2,
      streak: 6,
    ),
    (
      title: 'Медитация',
      subtitle: 'Каждый день, 15 минут',
      icon: AppIcons.meditation,
      color: 7,
      streak: 22,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _samples.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sample = _samples[index];
        final color = AppColors.habitPalette[sample.color];

        return _PreviewCard(
          title: sample.title,
          subtitle: sample.subtitle,
          icon: sample.icon,
          color: color,
          streak: sample.streak,
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.streak,
  });

  final String title;
  final String subtitle;
  final AppIconData icon;
  final Color color;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          WdIcon(icon, color: color, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    WdIcon(
                      AppIcons.fire,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$streak',
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: WdIcon(AppIcons.add, size: 20, color: color),
          ),
        ],
      ),
    );
  }
}
