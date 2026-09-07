import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/habit_visuals.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/pickers.dart';
import '../../../../core/widgets/wd_button.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_template.dart';
import '../../domain/entities/repeat_rule.dart';
import '../bloc/habits_bloc.dart';
import '../widgets/habit_form_sheets.dart';

/// Форма новой привычки.
///
/// Открывается из списка шаблонов: если [template] передан, поля заполняются
/// заранее, иначе — пустая привычка. Сохранение уходит через `HabitsBloc`,
/// он же после успеха перезапрашивает список на «Сегодня».
class HabitEditPage extends StatefulWidget {
  const HabitEditPage({this.template, super.key});

  final HabitTemplate? template;

  @override
  State<HabitEditPage> createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.template?.title ?? '',
  );
  final FocusNode _titleFocus = FocusNode();

  late String _icon = widget.template?.icon ?? 'check';
  late String _color = widget.template?.color ?? HabitColors.palette.first;
  late HabitType _type = widget.template?.type ?? HabitType.good;
  late RepeatRule _repeat = widget.template?.repeatRule ?? const DailyRepeat();
  late GoalDraft _goal = GoalDraft(
    value: widget.template?.goalValue,
    unit: widget.template?.goalUnit,
    type: widget.template?.goalType ?? GoalType.atLeast,
  );

  String? _groupId;
  String _description = '';
  List<Reminder> _reminders = const [];
  String? _titleError;

  @override
  void initState() {
    super.initState();
    // Список групп нужен панели выбора — грузим один раз заранее.
    ensureGroupsLoaded(context);
    // Сбрасываем результат прошлого сохранения, иначе экран закроется сразу.
    context.read<HabitsBloc>().add(const HabitsNoticeCleared());
    _titleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = AppStrings.errTitleRequired);
      _titleFocus.requestFocus();
      return;
    }

    setState(() => _titleError = null);
    FocusScope.of(context).unfocus();

    // `id` пустой — сервер выдаст настоящий.
    final draft = Habit(
      id: '',
      groupId: _groupId,
      title: title,
      icon: _icon,
      color: _color,
      type: _type,
      description: _description.isEmpty ? null : _description,
      goalValue: _goal.value,
      goalUnit: _goal.value == null ? null : _goal.unit,
      goalType: _goal.value == null ? null : _goal.type,
      repeatRule: _repeat,
      reminders: _reminders,
      order: 0,
      isArchived: false,
      createdAt: DateTime.now(),
    );

    context.read<HabitsBloc>().add(HabitCreateSubmitted(draft));
  }

  @override
  Widget build(BuildContext context) {
    final accent = HabitColors.parse(_color);

    return BlocListener<HabitsBloc, HabitsState>(
      listenWhen: (previous, current) => previous.noticeId != current.noticeId,
      listener: (context, state) {
        if (state.createdHabit != null) {
          // Список шаблонов тоже закрываем — возвращаемся сразу на «Сегодня».
          context.go(AppRoutes.today);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text(AppStrings.habitCreated)),
            );
          return;
        }

        final failure = state.failure;
        if (failure != null) {
          final titleError = failure.fieldErrors['title'];
          if (titleError != null) setState(() => _titleError = titleError);

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      child: BlocBuilder<HabitsBloc, HabitsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text(AppStrings.newHabit),
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: const WdIcon(AppIcons.chevronLeft, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceHigh,
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _PreviewCard(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  emojiKey: _icon,
                  accent: accent,
                  subtitle: _subtitle(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _titleError ??
                          '${_titleController.text.characters.length}/100',
                      style: AppTextStyles.caption.copyWith(
                        color: _titleError == null
                            ? AppColors.textTertiary
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const _SectionTitle(AppStrings.appearance),
                CardGroup(
                  children: [
                    EmojiListTile(
                      emojiKey: 'art',
                      title: AppStrings.colorLabel,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const WdIcon(
                            AppIcons.unfoldMore,
                            size: 20,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                      onTap: () async {
                        final picked = await ColorPickerSheet.show(
                          context,
                          _color,
                        );
                        if (picked != null) setState(() => _color = picked);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'check',
                      title: AppStrings.iconLabel,
                      trailing: _Trailing(
                        text: HabitEmoji.resolve(_icon),
                        isEmoji: true,
                      ),
                      onTap: () async {
                        final picked = await EmojiPickerSheet.show(
                          context,
                          _icon,
                        );
                        if (picked != null) setState(() => _icon = picked);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'journal',
                      title: AppStrings.descriptionLabel,
                      trailing: _Trailing(
                        text: _description.isEmpty
                            ? AppStrings.descriptionEmpty
                            : _description,
                      ),
                      onTap: () async {
                        final picked = await DescriptionSheet.show(
                          context,
                          _description,
                        );
                        if (picked != null) {
                          setState(() => _description = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const _SectionTitle(AppStrings.general),
                CardGroup(
                  children: [
                    EmojiListTile(
                      emojiKey: 'check',
                      title: AppStrings.typeLabel,
                      trailing: _Trailing(text: _typeLabel()),
                      onTap: () async {
                        final picked = await HabitTypeSheet.show(
                          context,
                          _type,
                        );
                        if (picked != null) setState(() => _type = picked);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'folder',
                      title: AppStrings.groupLabel,
                      trailing: _Trailing(text: _groupLabel(context)),
                      onTap: () async {
                        final (changed, groupId) = await GroupPickerSheet.show(
                          context,
                          _groupId,
                        );
                        if (changed) setState(() => _groupId = groupId);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'target',
                      title: AppStrings.goalLabel,
                      trailing: _Trailing(text: _goalLabel()),
                      onTap: () async {
                        final picked = await GoalSheet.show(context, _goal);
                        if (picked != null) setState(() => _goal = picked);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'daily',
                      title: AppStrings.repeatLabel,
                      trailing: _Trailing(text: _repeatLabel()),
                      onTap: () async {
                        final picked = await RepeatSheet.show(context, _repeat);
                        if (picked != null) setState(() => _repeat = picked);
                      },
                    ),
                    EmojiListTile(
                      emojiKey: 'alarm',
                      title: AppStrings.remindersLabel,
                      trailing: _Trailing(
                        text: _reminders.isEmpty
                            ? AppStrings.remindersEmpty
                            : _reminders.map((r) => r.json).join(', '),
                      ),
                      onTap: () async {
                        final picked = await RemindersSheet.show(
                          context,
                          _reminders,
                        );
                        if (picked != null) {
                          setState(() => _reminders = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: WdPrimaryButton(
                  label: AppStrings.continueAction,
                  isLoading: state.isSubmitting,
                  onPressed: _submit,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Подписи в строках ---

  String _typeLabel() => switch (_type) {
    HabitType.good => AppStrings.typeGood,
    HabitType.bad => AppStrings.typeBad,
    HabitType.task => AppStrings.typeTask,
  };

  String _groupLabel(BuildContext context) {
    if (_groupId == null) return AppStrings.noGroup;

    final groups = context.read<GroupsBloc>().state.groups;
    for (final group in groups) {
      if (group.id == _groupId) return group.name;
    }
    return AppStrings.noGroup;
  }

  String _goalLabel() {
    final value = _goal.value;
    if (value == null) return AppStrings.goalNone;

    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    return '$text ${_goal.unit ?? ''}'.trim();
  }

  String _repeatLabel() => switch (_repeat) {
    DailyRepeat() => AppStrings.everyDay,
    WeeklyRepeat(:final days) =>
      days.map((d) => AppStrings.weekdayShort[d - 1]).join(', '),
    IntervalRepeat(:final everyNDays) => AppStrings.everyNDays.replaceFirst(
      '%s',
      '$everyNDays',
    ),
  };

  /// Подпись под названием в карточке-превью — та же, что будет на «Сегодня».
  String _subtitle() {
    final schedule = _repeatLabel();
    final goal = _goalLabel();
    return goal == AppStrings.goalNone ? schedule : '$schedule, $goal';
  }
}

/// Цветная карточка сверху: так привычка будет выглядеть в списке.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.controller,
    required this.focusNode,
    required this.emojiKey,
    required this.accent,
    required this.subtitle,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String emojiKey;
  final Color accent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Row(
        children: [
          Text(
            HabitEmoji.resolve(emojiKey),
            style: const TextStyle(fontSize: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  maxLength: 100,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  cursorColor: AppColors.textOnPrimary,
                  decoration: InputDecoration(
                    counterText: '',
                    isDense: true,
                    hintText: AppStrings.titleHint,
                    hintStyle: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.55),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: focusNode.requestFocus,
            icon: const WdIcon(
              AppIcons.edit,
              size: 20,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Правая часть строки: значение + шеврон.
class _Trailing extends StatelessWidget {
  const _Trailing({required this.text, this.isEmoji = false});

  final String text;
  final bool isEmoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: isEmoji
                ? const TextStyle(fontSize: 20)
                : AppTextStyles.bodyMuted,
          ),
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
