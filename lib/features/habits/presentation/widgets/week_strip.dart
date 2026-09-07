import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/api_date.dart';

/// Yuqoridagi hafta qatori — screenshotdagi Пт/Сб/Вс… satri.
///
/// Dushanbadan boshlanadi (backend ham `1 = Dushanba` deb hisoblaydi).
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = ApiDate.dayOnly(DateTime.now());
    // Tanlangan kun qaysi haftada bo'lsa, o'sha hafta ko'rsatiladi.
    final monday = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = ApiDate.dayOnly(monday.add(Duration(days: index)));
          final isSelected = ApiDate.isSameDay(date, selectedDate);
          final isToday = ApiDate.isSameDay(date, today);
          final isFuture = date.isAfter(today);

          return Expanded(
            child: InkWell(
              onTap: () => onDateSelected(date),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Text(
                      AppStrings.weekdayShort[index],
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 36,
                      width: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        // Bugungi kun tanlanmagan bo'lsa ham ajralib tursin.
                        border: !isSelected && isToday
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        '${date.day}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.textOnPrimary
                              // Kelajakdagi kunlar so'nikroq.
                              : isFuture
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
