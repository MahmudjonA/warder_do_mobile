import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/widgets/wd_icon.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../groups/presentation/bloc/groups_bloc.dart';
import '../../../programs/presentation/pages/program_import_sheet.dart';
import '../../domain/entities/daily_habit.dart';
import '../bloc/habits_bloc.dart';
import '../widgets/habit_card.dart';
import '../widgets/habit_group_section.dart';
import '../widgets/habit_sheets.dart';
import '../widgets/week_strip.dart';

/// Bosh ekran: hafta qatori + tanlangan kunning odatlari.
///
/// Butun ekran uchun **bitta** so'rov ketadi (`GET /habits?date=`), chunki
/// server har bir odatga o'sha kungi logni qo'shib beradi.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitsBloc, HabitsState>(
      // Snackbar va yutuq oynasi — faqat yangi xabar kelganda.
      listenWhen: (previous, current) =>
          previous.noticeId != current.noticeId ||
          previous.unlockId != current.unlockId,
      listener: _handleNotices,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                _TopBar(state: state),
                WeekStrip(
                  selectedDate: state.selectedDate,
                  onDateSelected: (date) =>
                      context.read<HabitsBloc>().add(HabitsDateSelected(date)),
                ),
                // Kun progressi — faqat o'sha kunda odat bo'lsa ko'rsatiladi.
                if (state.habits.isNotEmpty) _DayProgress(state: state),
                const SizedBox(height: 4),
                Expanded(child: _Body(state: state)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleNotices(BuildContext context, HabitsState state) {
    final notice = state.notice;
    if (notice != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const WdIcon(
                  AppIcons.alert,
                  size: 20,
                  color: AppColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(notice)),
              ],
            ),
          ),
        );
      context.read<HabitsBloc>().add(const HabitsNoticeCleared());
    }

    if (state.newlyUnlocked.isNotEmpty) {
      // Bir vaqtda bir nechta yutuq ochilishi mumkin — birinchisini
      // ko'rsatamiz, qolganlari yutuqlar ekranida ko'rinadi.
      AchievementDialog.show(context, state.newlyUnlocked.first);
      context.read<HabitsBloc>().add(const HabitsUnlockDismissed());
    }
  }
}

/// Верхняя панель: слева — кнопка списка/сортировки, по центру дата,
/// справа — «плюс» и поиск.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});

  final HabitsState state;

  /// Ширина боковых блоков одинаковая, чтобы заголовок стоял ровно по центру.
  static const double _sideWidth = 96;

  @override
  Widget build(BuildContext context) {
    final isToday = ApiDate.isToday(state.selectedDate);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      child: Row(
        children: [
          SizedBox(
            width: _sideWidth,
            // Кнопка одна — прижимаем к левому краю, без лишнего отступа слева.
            child: Align(
              alignment: Alignment.centerLeft,
              child: _Pill(
                children: [
                  // Единственная кнопка слева — «Изменить порядок».
                  // Шаблоны групп доступны оттуда же, через «Группы».
                  _PillIcon(
                    icon: AppIcons.list,
                    onTap: () async {
                      await context.push(AppRoutes.organizer);
                      if (!context.mounted) return;
                      // Там могли поменять группы и порядок — перечитываем.
                      context.read<HabitsBloc>().add(
                        const HabitsRequested(silent: true),
                      );
                      context.read<GroupsBloc>().add(const GroupsRequested());
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isToday ? AppStrings.today : _formatDate(state.selectedDate),
                  style: AppTextStyles.title,
                ),
                Text(
                  _weekdayLabel(state.selectedDate),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          SizedBox(
            width: _sideWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _CircleIcon(
                  icon: AppIcons.add,
                  onTap: () async {
                    await context.push(AppRoutes.habitPicker);
                    if (!context.mounted) return;
                    context.read<HabitsBloc>().add(
                      const HabitsRequested(silent: true),
                    );
                  },
                ),
                // AI orqali dastur (program) import qilish.
                const SizedBox(width: 10),
                _CircleIcon(
                  icon: AppIcons.import,
                  onTap: () async {
                    final created = await showProgramImportSheet(context);
                    if (created == true && context.mounted) {
                      context.read<HabitsBloc>().add(
                        const HabitsRequested(silent: true),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day} ${AppStrings.months[date.month - 1]}';

  static String _weekdayLabel(DateTime date) =>
      AppStrings.weekdayFull[date.weekday - 1];
}

/// Kun progressi: bugun nechta odat bajarilganini yumshoq gradient bar bilan
/// ko'rsatadi. Karta faqat o'sha kunda odat bo'lganda chiqadi.
class _DayProgress extends StatelessWidget {
  const _DayProgress({required this.state});

  final HabitsState state;

  @override
  Widget build(BuildContext context) {
    final total = state.habits.length;
    final done = state.completedCount;
    final progress = state.dayProgress.clamp(0.0, 1.0);
    final allDone = done >= total && total > 0;
    final percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  allDone ? AppStrings.progressAllDone : AppStrings.progressToday,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: allDone ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$done/$total · $percent%',
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: allDone ? AppColors.success : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Yumshoq animatsiya: qiymat o'zgarganda bar suriladi.
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: progress),
                    builder: (context, value, _) {
                      return Container(
                        height: 8,
                        width: maxWidth * value,
                        decoration: BoxDecoration(
                          gradient: allDone ? null : AppColors.heroGradient,
                          color: allDone ? AppColors.success : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Скруглённый блок из нескольких иконок.
class _Pill extends StatelessWidget {
  const _Pill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon, required this.onTap});

  final AppIconData icon;

  /// `null` — кнопка неактивна (функция ещё не подключена).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 44,
        width: 44,
        child: WdIcon(
          icon,
          size: 20,
          color: onTap == null ? AppColors.textTertiary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});

  final AppIconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 40,
          width: 40,
          child: WdIcon(
            icon,
            size: 20,
            color: onTap == null
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Список привычек, разложенный по группам.
///
/// Группы приходят из `GroupsBloc`, привычки — из `HabitsBloc`; связь по
/// `groupId`. Свёрнутые группы храним прямо здесь: это состояние экрана,
/// серверу оно не нужно.
class _Body extends StatefulWidget {
  const _Body({required this.state});

  final HabitsState state;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final Set<String> _collapsed = {};

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    if (state.status == HabitsStatus.loading && state.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == HabitsStatus.failure && state.habits.isEmpty) {
      return _ErrorView(
        message: state.failure?.message ?? AppStrings.errUnknown,
      );
    }

    if (state.habits.isEmpty) return const _EmptyView();

    final groups = context.select((GroupsBloc bloc) => bloc.state.groups);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        context.read<HabitsBloc>().add(const HabitsRequested(silent: true));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: _sections(context, state, groups),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    HabitsState state,
    List<Group> groups,
  ) {
    final widgets = <Widget>[];

    for (final group in groups) {
      final items = state.habits
          .where((item) => item.habit.groupId == group.id)
          .toList();
      // Пустую группу на сегодня не показываем — она только шумит.
      if (items.isEmpty) continue;

      widgets
        ..add(
          HabitGroupSection(
            group: group,
            collapsed: _collapsed.contains(group.id),
            onToggle: () => setState(() {
              _collapsed.contains(group.id)
                  ? _collapsed.remove(group.id)
                  : _collapsed.add(group.id);
            }),
            children: [for (final item in items) _card(context, state, item)],
          ),
        )
        ..add(const SizedBox(height: 14));
    }

    // Привычки без группы идут просто списком, без заголовка.
    final ungrouped = state.habits
        .where((item) => item.habit.groupId == null)
        .toList();

    for (var i = 0; i < ungrouped.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 10));
      widgets.add(_card(context, state, ungrouped[i]));
    }

    return widgets;
  }

  Widget _card(BuildContext context, HabitsState state, DailyHabit item) {
    return HabitCard(
      key: ValueKey(item.habit.id),
      item: item,
      isPending: state.isPending(item.habit.id),
      // Faqat bugungi kunni belgilash mumkin — o'tgan va kelajak kunlar
      // "ko'rish uchun", lekin bosilmaydi (backend ham ularni rad etadi).
      enabled: ApiDate.isToday(state.selectedDate),
      onPrimaryAction: () => _onPrimaryAction(context, item),
      onLongPress: () => _onLongPress(context, item),
    );
  }

  Future<void> _onPrimaryAction(BuildContext context, DailyHabit item) async {
    final bloc = context.read<HabitsBloc>();

    // Программа тренировок — сначала показываем нагрузку дня (сколько подходов)
    // и заметку тренера, а отметить «выполнено» можно кнопкой в панели.
    if (item.programDay != null) {
      final toggle = await ProgramDaySheet.show(context, item);
      if (toggle == true) bloc.add(HabitToggled(item.habit.id));
      return;
    }

    // Привычка без цели или уже выполненная — обычное переключение.
    if (!item.habit.hasGoal || item.isCompleted) {
      bloc.add(HabitToggled(item.habit.id));
      return;
    }

    final amount = await LogValueSheet.show(context, item);
    if (amount == null) return;

    bloc.add(HabitValueAdded(habitId: item.habit.id, amount: amount));
  }

  Future<void> _onLongPress(BuildContext context, DailyHabit item) async {
    final bloc = context.read<HabitsBloc>();
    final action = await HabitActionsSheet.show(context, item);

    if (action == HabitQuickAction.clearLog) {
      bloc.add(HabitLogCleared(item.habit.id));
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Bo'sh bo'lsa ham tortib yangilash ishlashi uchun ListView.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Center(
          child: Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius + 8),
            ),
            child: const Center(
              child: Text('🌱', style: TextStyle(fontSize: 36)),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          AppStrings.todayEmptyTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.todayEmptyBody,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () =>
                  context.read<HabitsBloc>().add(const HabitsRequested()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
