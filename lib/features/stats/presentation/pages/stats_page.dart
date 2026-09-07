import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// Вкладка «Статистика».
///
/// Пока заглушка: слой данных уже готов (`ProgressRepository` умеет
/// `GET /stats/overview` и `GET /achievements`), осталось добавить блок
/// и сам экран.
class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.tabStats)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radius + 8),
                ),
                child: const Center(
                  child: Text('📊', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                AppStrings.statsSoonTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 6),
              const Text(
                AppStrings.statsSoonBody,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
