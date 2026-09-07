import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/device_timezone.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../../../../core/widgets/wd_settings_tile.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_notice_listener.dart';

/// Profil — screenshotlardagi sozlamalar bloklari uslubida.
///
/// `PATCH /auth/me` faqat ikkita maydonni o'zgartiradi: ism va timezone.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthNoticeListener(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text(AppStrings.profileTitle)),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<AuthBloc>().add(const AuthUserRefreshed());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _ProfileHeader(
                    initials: user.initials,
                    name: user.displayName,
                    email: user.email,
                  ),
                  const SizedBox(height: 32),

                  WdSettingsGroup(
                    title: AppStrings.account,
                    children: [
                      WdSettingsTile(
                        icon: AppIcons.user,
                        iconColor: AppColors.habitPalette[4],
                        title: AppStrings.fullName,
                        value: user.fullName ?? '—',
                        onTap: state.isSubmitting
                            ? null
                            : () => _editName(context, user.fullName),
                      ),
                      WdSettingsTile(
                        icon: AppIcons.email,
                        iconColor: AppColors.habitPalette[2],
                        title: AppStrings.email,
                        value: user.email,
                        // Email `PATCH /auth/me` orqali o'zgarmaydi —
                        // shuning uchun bosilmaydi.
                      ),
                      WdSettingsTile(
                        icon: AppIcons.globe,
                        iconColor: AppColors.habitPalette[1],
                        title: AppStrings.timezone,
                        value: user.timezone,
                        onTap: state.isSubmitting
                            ? null
                            : () => _editTimezone(context, user.timezone),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  WdSettingsGroup(
                    title: AppStrings.session,
                    children: [
                      WdSettingsTile(
                        icon: AppIcons.logout,
                        iconColor: AppColors.danger,
                        title: AppStrings.logout,
                        isDestructive: true,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      '${AppStrings.registeredAt}'
                      '${_formatDate(user.createdAt.toLocal())}',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';

  Future<void> _editName(BuildContext context, String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final bloc = context.read<AuthBloc>();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _NameSheet(controller: controller),
    );

    if (result != null) {
      bloc.add(AuthProfileUpdated(fullName: result));
    }
    controller.dispose();
  }

  Future<void> _editTimezone(BuildContext context, String current) async {
    final bloc = context.read<AuthBloc>();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _TimezoneSheet(current: current),
    );

    if (result != null && result != current) {
      bloc.add(AuthProfileUpdated(timezone: result));
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.logoutConfirmTitle),
        content: const Text(
          AppStrings.logoutConfirmBody,
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // Router `AuthStatus.unauthenticated` ni ko'rib o'zi welcome'ga oladi.
      bloc.add(const AuthLogoutRequested());
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
  });

  final String initials;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88,
          width: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Text(
            initials,
            style: AppTextStyles.display.copyWith(fontSize: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.title),
        const SizedBox(height: 4),
        Text(email, style: AppTextStyles.bodyMuted),
      ],
    );
  }
}

/// Ismni tahrirlash uchun pastdan chiqadigan panel.
class _NameSheet extends StatelessWidget {
  const _NameSheet({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.fullName, style: AppTextStyles.title),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            maxLength: 255,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceInput,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              ),
            ),
            child: const Text(AppStrings.save, style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

/// Timezone tanlash paneli.
class _TimezoneSheet extends StatelessWidget {
  const _TimezoneSheet({required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    // Foydalanuvchining joriy zonasi ro'yxatda bo'lmasligi mumkin —
    // uni boshiga qo'shamiz, aks holda tanlangan qiymat ko'rinmay qoladi.
    final zones = <String>{current, ...DeviceTimezone.common}.toList();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(AppStrings.timezone, style: AppTextStyles.title),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                final selected = zone == current;

                return ListTile(
                  title: Text(
                    zone,
                    style: AppTextStyles.body.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: selected
                      ? const WdIcon(
                          AppIcons.check,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(zone),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
