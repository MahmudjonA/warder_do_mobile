import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../groups/domain/entities/group.dart';
import '../../../groups/domain/usecases/group_usecases.dart';
import '../../domain/entities/daily_habit.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/habit_usecases.dart';

part 'organizer_event.dart';
part 'organizer_state.dart';

/// Экран «Изменить порядок».
///
/// Порядок меняется локально и мгновенно, на сервер уходит одним пакетом
/// по кнопке-галочке. Так перетаскивание не упирается в сеть, а сервер не
/// получает по запросу на каждое движение пальцем.
class OrganizerBloc extends Bloc<OrganizerEvent, OrganizerState> {
  OrganizerBloc({
    required GetDailyHabits getDailyHabits,
    required GetGroups getGroups,
    required ReorderHabits reorderHabits,
    required ReorderGroups reorderGroups,
    required MoveHabitToGroup moveHabitToGroup,
    required DeleteHabit deleteHabit,
    required ArchiveHabit archiveHabit,
    required DeleteGroup deleteGroup,
  }) : _getDailyHabits = getDailyHabits,
       _getGroups = getGroups,
       _reorderHabits = reorderHabits,
       _reorderGroups = reorderGroups,
       _moveHabitToGroup = moveHabitToGroup,
       _deleteHabit = deleteHabit,
       _archiveHabit = archiveHabit,
       _deleteGroup = deleteGroup,
       super(const OrganizerState()) {
    on<OrganizerRequested>(_onRequested);
    on<OrganizerArrangementChanged>(_onArrangementChanged);
    on<OrganizerHabitDeleted>(_onHabitDeleted);
    on<OrganizerHabitArchived>(_onHabitArchived);
    on<OrganizerGroupDeleted>(_onGroupDeleted);
    on<OrganizerSaved>(_onSaved);
    on<OrganizerNoticeCleared>(
      (event, emit) => emit(state.copyWith(clearNotice: true)),
    );
  }

  final GetDailyHabits _getDailyHabits;
  final GetGroups _getGroups;
  final ReorderHabits _reorderHabits;
  final ReorderGroups _reorderGroups;
  final MoveHabitToGroup _moveHabitToGroup;
  final DeleteHabit _deleteHabit;
  final ArchiveHabit _archiveHabit;
  final DeleteGroup _deleteGroup;

  Future<void> _onRequested(
    OrganizerRequested event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(state.copyWith(status: OrganizerStatus.loading, clearNotice: true));

    // Здесь нужны все привычки, а не только сегодняшние, — иначе часть
    // списка просто не покажется.
    final habitsResult = await _getDailyHabits(
      const DailyHabitsParams(all: true),
    );
    final groupsResult = await _getGroups(const NoParams());

    final failure =
        habitsResult.fold<Failure?>((f) => f, (_) => null) ??
        groupsResult.fold<Failure?>((f) => f, (_) => null);

    if (failure != null) {
      emit(state.copyWith(status: OrganizerStatus.failure, failure: failure));
      return;
    }

    final habits = habitsResult
        .getOrElse(() => const <DailyHabit>[])
        .map((item) => item.habit)
        .toList();
    final groups = groupsResult.getOrElse(() => const <Group>[]);

    emit(
      state.copyWith(
        status: OrganizerStatus.ready,
        groups: groups,
        habits: _sorted(habits),
        // Снимок исходного состояния: по нему поймём, что реально менять.
        initialOrder: habits.map((h) => h.id).toList(),
        initialGroups: {for (final h in habits) h.id: h.groupId},
        initialGroupOrder: groups.map((g) => g.id).toList(),
        isDirty: false,
      ),
    );
  }

  void _onArrangementChanged(
    OrganizerArrangementChanged event,
    Emitter<OrganizerState> emit,
  ) {
    emit(
      state.copyWith(habits: event.habits, groups: event.groups, isDirty: true),
    );
  }

  Future<void> _onHabitDeleted(
    OrganizerHabitDeleted event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _deleteHabit(event.habitId);

    result.fold(
      (failure) => emit(_withNotice(failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          habits: state.habits.where((h) => h.id != event.habitId).toList(),
        ),
      ),
    );
  }

  Future<void> _onHabitArchived(
    OrganizerHabitArchived event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _archiveHabit(event.habitId);

    result.fold(
      (failure) => emit(_withNotice(failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          // Архивная привычка в списке не нужна — она уже не «активная».
          habits: state.habits.where((h) => h.id != event.habitId).toList(),
        ),
      ),
    );
  }

  Future<void> _onGroupDeleted(
    OrganizerGroupDeleted event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _deleteGroup(event.groupId);

    result.fold(
      (failure) => emit(_withNotice(failure.message)),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          groups: state.groups.where((g) => g.id != event.groupId).toList(),
          // Сервер привычки не удаляет — они остаются без группы.
          habits: [
            for (final habit in state.habits)
              if (habit.groupId == event.groupId)
                habit.copyWith(clearGroup: true)
              else
                habit,
          ],
        ),
      ),
    );
  }

  /// Сохраняем всё разом: смену групп, порядок привычек и порядок групп.
  Future<void> _onSaved(
    OrganizerSaved event,
    Emitter<OrganizerState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    // 1. Привычки, у которых сменилась группа.
    for (final habit in state.habits) {
      if (state.initialGroups[habit.id] == habit.groupId) continue;

      final result = await _moveHabitToGroup(
        MoveHabitParams(habitId: habit.id, groupId: habit.groupId),
      );
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        emit(_withNotice(failure.message));
        return;
      }
    }

    // 2. Порядок привычек — одним запросом.
    final order = state.habits.map((h) => h.id).toList();
    if (!_sameOrder(order, state.initialOrder)) {
      final result = await _reorderHabits(order);
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        emit(_withNotice(failure.message));
        return;
      }
    }

    // 3. Порядок групп.
    final groupOrder = state.groups.map((g) => g.id).toList();
    if (!_sameOrder(groupOrder, state.initialGroupOrder)) {
      final result = await _reorderGroups(groupOrder);
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure != null) {
        emit(_withNotice(failure.message));
        return;
      }
    }

    emit(
      state.copyWith(
        isSubmitting: false,
        isDirty: false,
        isSaved: true,
        noticeId: state.noticeId + 1,
      ),
    );
  }

  // --- Вспомогательное ---

  OrganizerState _withNotice(String message) => state.copyWith(
    isSubmitting: false,
    notice: message,
    noticeId: state.noticeId + 1,
  );

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Сервер отдаёт привычки по `order`, но группы при этом перемешаны —
  /// раскладываем по группам, чтобы секции шли подряд.
  List<Habit> _sorted(List<Habit> habits) {
    final sorted = [...habits]..sort((a, b) => a.order.compareTo(b.order));
    return sorted;
  }
}
