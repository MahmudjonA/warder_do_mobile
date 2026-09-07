import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pickers.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../../data/habit_template_catalog.dart';
import '../../domain/entities/habit_template.dart';

/// «+» на главном экране открывает этот список.
///
/// Каталог полностью локальный — ровно как у групп: экран не делает ни одного
/// запроса, открывается мгновенно и работает без интернета. Выбор шаблона
/// только заполняет форму, `POST /habits` уходит уже из неё.
class HabitPickerPage extends StatefulWidget {
  const HabitPickerPage({super.key});

  @override
  State<HabitPickerPage> createState() => _HabitPickerPageState();
}

class _HabitPickerPageState extends State<HabitPickerPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sections = HabitTemplateCatalog.search(_query);
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.chooseHabit),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const WdIcon(AppIcons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              shape: const CircleBorder(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: sections.isEmpty
                ? const Center(
                    child: Text(
                      AppStrings.nothingFound,
                      style: AppTextStyles.bodyMuted,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      // Во время поиска этот блок только мешает.
                      if (!isSearching) ...[
                        _SectionTitle(AppStrings.customSection),
                        CardGroup(
                          children: [
                            EmojiListTile(
                              emojiKey: 'star',
                              title: AppStrings.customHabit,
                              onTap: () => context.push(AppRoutes.habitEdit),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      for (final section in sections) ...[
                        _SectionTitle(section.title),
                        CardGroup(
                          children: [
                            for (final template in section.templates)
                              EmojiListTile(
                                emojiKey: template.icon,
                                title: template.title,
                                trailing: _GoalHint(template: template),
                                onTap: () => context.push(
                                  AppRoutes.habitEdit,
                                  extra: template,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
          ),
          _SearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10),
      child: Text(title, style: AppTextStyles.sectionLabel),
    );
  }
}

/// Короткая подсказка справа: «2 литров», «20 страниц».
class _GoalHint extends StatelessWidget {
  const _GoalHint({required this.template});

  final HabitTemplate template;

  @override
  Widget build(BuildContext context) {
    final value = template.goalValue;
    if (value == null) {
      return const WdIcon(
        AppIcons.chevronRight,
        size: 22,
        color: AppColors.textTertiary,
      );
    }

    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$text ${template.goalUnit ?? ''}'.trim(),
          style: AppTextStyles.caption,
        ),
        const SizedBox(width: 6),
        const WdIcon(
          AppIcons.chevronRight,
          size: 22,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }
}

/// Поле поиска внизу — как на экране шаблонов групп.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: AppStrings.searchHabits,
          hintStyle: AppTextStyles.bodyMuted,
          prefixIcon: const WdIcon(
            AppIcons.search,
            color: AppColors.textTertiary,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
