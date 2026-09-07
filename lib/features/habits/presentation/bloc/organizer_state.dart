part of 'organizer_bloc.dart';

enum OrganizerStatus { initial, loading, ready, failure }

class OrganizerState extends Equatable {
  const OrganizerState({
    this.status = OrganizerStatus.initial,
    this.groups = const [],
    this.habits = const [],
    this.initialOrder = const [],
    this.initialGroups = const {},
    this.initialGroupOrder = const [],
    this.isDirty = false,
    this.isSubmitting = false,
    this.isSaved = false,
    this.failure,
    this.notice,
    this.noticeId = 0,
  });

  final OrganizerStatus status;

  /// Группы в текущем порядке экрана.
  final List<Group> groups;

  /// Все привычки одним списком; принадлежность к группе — в `groupId`.
  final List<Habit> habits;

  /// Снимок при загрузке: по нему считаем, что реально изменилось.
  final List<String> initialOrder;
  final Map<String, String?> initialGroups;
  final List<String> initialGroupOrder;

  /// Есть несохранённые перестановки — галочка становится активной.
  final bool isDirty;

  final bool isSubmitting;

  /// Сохранение прошло — экран можно закрывать.
  final bool isSaved;

  final Failure? failure;
  final String? notice;
  final int noticeId;

  /// Привычки конкретной группы, в порядке общего списка.
  List<Habit> habitsOf(String? groupId) =>
      habits.where((h) => h.groupId == groupId).toList();

  /// Привычки без группы — на экране они идут последней секцией.
  List<Habit> get ungrouped => habitsOf(null);

  bool get isEmpty => habits.isEmpty && groups.isEmpty;

  OrganizerState copyWith({
    OrganizerStatus? status,
    List<Group>? groups,
    List<Habit>? habits,
    List<String>? initialOrder,
    Map<String, String?>? initialGroups,
    List<String>? initialGroupOrder,
    bool? isDirty,
    bool? isSubmitting,
    bool? isSaved,
    Failure? failure,
    String? notice,
    int? noticeId,
    bool clearNotice = false,
  }) {
    return OrganizerState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      habits: habits ?? this.habits,
      initialOrder: initialOrder ?? this.initialOrder,
      initialGroups: initialGroups ?? this.initialGroups,
      initialGroupOrder: initialGroupOrder ?? this.initialGroupOrder,
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSaved: clearNotice ? false : (isSaved ?? this.isSaved),
      failure: clearNotice ? null : (failure ?? this.failure),
      notice: clearNotice ? null : (notice ?? this.notice),
      noticeId: noticeId ?? this.noticeId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    habits,
    initialOrder,
    initialGroups,
    initialGroupOrder,
    isDirty,
    isSubmitting,
    isSaved,
    failure,
    notice,
    noticeId,
  ];
}
