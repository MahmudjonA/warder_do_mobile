import 'package:flutter/material.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../../domain/entities/stats_entities.dart';

/// "Записи" bloki: 4 ta katta raqam + davr tanlagichi (7 / 30 / 90 kun).
class StatsRecordsCard extends StatelessWidget {
  const StatsRecordsCard({
    required this.records,
    required this.period,
    required this.loading,
    required this.onPeriodChanged,
    super.key,
  });

  final StatsRecords? records;
  final RecordsPeriod period;
  final bool loading;
  final ValueChanged<RecordsPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final r = records;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius + 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                AppStrings.statsRecords,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                onTap: () => _pickPeriod(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _periodLabel(period),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const WdIcon(
                        AppIcons.chevronRight,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '${r?.currentStreak ?? 0}',
                  label: AppStrings.statsCurrentStreak,
                  emoji: '🔥',
                  loading: loading,
                ),
              ),
              Expanded(
                child: _StatTile(
                  value: '${r?.longestStreak ?? 0}',
                  label: AppStrings.statsBestStreak,
                  emoji: '🏅',
                  loading: loading,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  value: '${r?.completed ?? 0}',
                  label: AppStrings.statsCompleted,
                  emoji: '✅',
                  loading: loading,
                ),
              ),
              Expanded(
                child: _StatTile(
                  value: '${r?.successRate ?? 0}%',
                  label: AppStrings.statsSuccessRate,
                  emoji: '🏁',
                  loading: loading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _pickPeriod(BuildContext context) async {
    final selected = await showModalBottomSheet<RecordsPeriod>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            for (final option in RecordsPeriod.values)
              ListTile(
                title: Text(_periodLabel(option), style: AppTextStyles.body),
                trailing: option == period
                    ? const WdIcon(
                        AppIcons.check,
                        size: 20,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected != null && selected != period) onPeriodChanged(selected);
  }

  static String _periodLabel(RecordsPeriod period) => switch (period) {
    RecordsPeriod.last7 => AppStrings.statsLast7,
    RecordsPeriod.last30 => AppStrings.statsLast30,
    RecordsPeriod.last90 => AppStrings.statsLast90,
  };
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.emoji,
    required this.loading,
  });

  final String value;
  final String label;
  final String emoji;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: loading ? 0.4 : 1,
                  child: Text(
                    value,
                    style: AppTextStyles.title.copyWith(fontSize: 26),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Text(emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
