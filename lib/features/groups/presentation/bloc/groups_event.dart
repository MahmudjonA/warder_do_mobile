part of 'groups_bloc.dart';

sealed class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class GroupsRequested extends GroupsEvent {
  const GroupsRequested();
}

/// Formadagi "saqlash" tugmasi. [id] `null` bo'lsa — yangi guruh.
class GroupSubmitted extends GroupsEvent {
  const GroupSubmitted({
    required this.name,
    required this.icon,
    required this.color,
    this.id,
  });

  final String? id;
  final String name;
  final String icon;
  final String color;

  @override
  List<Object?> get props => [id, name, icon, color];
}

class GroupDeleted extends GroupsEvent {
  const GroupDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class GroupsNoticeCleared extends GroupsEvent {
  const GroupsNoticeCleared();
}

/// Новый порядок групп после перетаскивания.
class GroupsReordered extends GroupsEvent {
  const GroupsReordered(this.orderedIds);

  final List<String> orderedIds;

  @override
  List<Object?> get props => [orderedIds];
}
