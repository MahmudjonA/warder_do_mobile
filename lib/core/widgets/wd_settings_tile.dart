import 'package:flutter/material.dart';

import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'wd_icon.dart';

/// Sozlamalar qatorlarini bitta yumaloq kartaga jamlaydi va orasiga
/// ingichka ajratuvchi qo'yadi — screenshotlardagi "Oformlenie" / "Osnovnye"
/// bloklarining aynan o'zi.
class WdSettingsGroup extends StatelessWidget {
  const WdSettingsGroup({required this.children, this.title, super.key});

  /// Karta ustidagi kulrang sarlavha.
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 10),
            child: Text(title!, style: AppTextStyles.sectionLabel),
          ),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  const Padding(
                    // Ajratuvchi ikonka ostidan boshlanmaydi — iOS uslubi.
                    padding: EdgeInsets.only(left: 60, right: 12),
                    child: Divider(height: 0.5),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// [WdSettingsGroup] ichidagi bitta qator.
class WdSettingsTile extends StatelessWidget {
  const WdSettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    super.key,
  });

  final AppIconData icon;
  final Color iconColor;
  final String title;

  /// O'ng tomondagi kulrang qiymat, masalan "Asia/Tashkent".
  final String? value;

  final VoidCallback? onTap;

  /// Chevron o'rniga boshqa element qo'yish uchun (Switch va h.k.).
  final Widget? trailing;

  /// Qizil matn — "Chiqish" kabi qaytarib bo'lmaydigan harakatlar uchun.
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDestructive ? AppColors.danger : AppColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: WdIcon(icon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.body.copyWith(color: titleColor),
                ),
              ),
              if (value != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMuted,
                  ),
                ),
              if (trailing != null)
                trailing!
              else if (onTap != null) ...[
                const SizedBox(width: 4),
                const WdIcon(
                  AppIcons.chevronRight,
                  size: 22,
                  color: AppColors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
