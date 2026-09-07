part of 'organizer_bloc.dart';

sealed class OrganizerEvent extends Equatable {
  const OrganizerEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить все привычки (`?all=true`) и группы.
class OrganizerRequested extends OrganizerEvent {
  const OrganizerRequested();
}

/// Экран пересобрал порядок и раздал привычкам группы.
///
/// Индексную арифметику держим в UI (там виден список), блок хранит уже
/// готовую расстановку — так проще и тестировать, и читать.
class OrganizerArrangementChanged extends OrganizerEvent {
  const OrganizerArrangementChanged({
    required this.habits,
    required this.groups,
  });

  final List<Habit> habits;
  final List<Group> groups;

  @override
  List<Object?> get props => [habits, groups];
}

/// Удалить привычку насовсем (вместе с историей).
class OrganizerHabitDeleted extends OrganizerEvent {
  const OrganizerHabitDeleted(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

/// Мягкая альтернатива удалению: история сохраняется.
class OrganizerHabitArchived extends OrganizerEvent {
  const OrganizerHabitArchived(this.habitId);

  final String habitId;

  @override
  List<Object?> get props => [habitId];
}

/// Удалить группу. Привычки внутри остаются, но без группы.
class OrganizerGroupDeleted extends OrganizerEvent {
  const OrganizerGroupDeleted(this.groupId);

  final String groupId;

  @override
  List<Object?> get props => [groupId];
}

/// Кнопка-галочка: отправить все изменения на сервер.
class OrganizerSaved extends OrganizerEvent {
  const OrganizerSaved();
}

class OrganizerNoticeCleared extends OrganizerEvent {
  const OrganizerNoticeCleared();
}
