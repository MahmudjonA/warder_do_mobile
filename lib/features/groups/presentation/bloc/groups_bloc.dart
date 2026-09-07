import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/group_usecases.dart';

part 'groups_event.dart';
part 'groups_state.dart';

/// Guruhlar ro'yxati va forma holati.
class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc({
    required GetGroups getGroups,
    required SaveGroup saveGroup,
    required DeleteGroup deleteGroup,
    required ReorderGroups reorderGroups,
  }) : _getGroups = getGroups,
       _saveGroup = saveGroup,
       _deleteGroup = deleteGroup,
       _reorderGroups = reorderGroups,
       super(const GroupsState()) {
    on<GroupsRequested>(_onRequested);
    on<GroupSubmitted>(_onSubmitted);
    on<GroupDeleted>(_onDeleted);
    on<GroupsReordered>(_onReordered);
    on<GroupsNoticeCleared>(
      (event, emit) => emit(state.copyWith(clearNotice: true)),
    );
  }

  final GetGroups _getGroups;
  final SaveGroup _saveGroup;
  final DeleteGroup _deleteGroup;
  final ReorderGroups _reorderGroups;

  Future<void> _onRequested(
    GroupsRequested event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(status: GroupsStatus.loading, clearNotice: true));

    final result = await _getGroups(const NoParams());

    result.fold(
      (failure) =>
          emit(state.copyWith(status: GroupsStatus.failure, failure: failure)),
      (groups) =>
          emit(state.copyWith(status: GroupsStatus.ready, groups: groups)),
    );
  }

  Future<void> _onSubmitted(
    GroupSubmitted event,
    Emitter<GroupsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _saveGroup(
      SaveGroupParams(
        id: event.id,
        name: event.name,
        icon: event.icon,
        color: event.color,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          failure: failure,
          noticeId: state.noticeId + 1,
        ),
      ),
      (group) => emit(
        state.copyWith(
          isSubmitting: false,
          // Ro'yxatni qayta so'ramaymiz: yangi guruhni o'rniga qo'yamiz.
          groups: _merge(state.groups, group),
          savedGroup: group,
          noticeId: state.noticeId + 1,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onDeleted(GroupDeleted event, Emitter<GroupsState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearNotice: true));

    final result = await _deleteGroup(event.id);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isSubmitting: false,
          failure: failure,
          noticeId: state.noticeId + 1,
        ),
      ),
      (_) => emit(
        state.copyWith(
          isSubmitting: false,
          groups: state.groups.where((g) => g.id != event.id).toList(),
          deletedId: event.id,
          noticeId: state.noticeId + 1,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onReordered(
    GroupsReordered event,
    Emitter<GroupsState> emit,
  ) async {
    // Список переставляем сразу — иначе он «прыгнет» обратно на время запроса.
    final byId = {for (final group in state.groups) group.id: group};
    final optimistic = [
      for (final id in event.orderedIds)
        if (byId[id] != null) byId[id]!,
    ];
    final previous = state.groups;

    emit(state.copyWith(groups: optimistic));

    final result = await _reorderGroups(event.orderedIds);

    result.fold(
      (failure) => emit(
        state.copyWith(
          groups: previous,
          failure: failure,
          noticeId: state.noticeId + 1,
        ),
      ),
      (groups) => emit(state.copyWith(groups: groups)),
    );
  }

  /// Yangilangan guruhni ro'yxatga qo'shadi yoki almashtiradi.
  List<Group> _merge(List<Group> source, Group group) {
    final exists = source.any((g) => g.id == group.id);
    if (!exists) return [...source, group];
    return [
      for (final g in source)
        if (g.id == group.id) group else g,
    ];
  }
}
