part of 'groups_bloc.dart';

enum GroupsStatus { initial, loading, ready, failure }

class GroupsState extends Equatable {
  const GroupsState({
    this.status = GroupsStatus.initial,
    this.groups = const [],
    this.isSubmitting = false,
    this.failure,
    this.savedGroup,
    this.deletedId,
    this.noticeId = 0,
  });

  final GroupsStatus status;
  final List<Group> groups;

  /// Forma yuborilib, javob kutilmoqda.
  final bool isSubmitting;

  final Failure? failure;

  /// Oxirgi muvaffaqiyatli saqlangan guruh — forma ekranini yopish uchun.
  final Group? savedGroup;

  final String? deletedId;

  /// Har bir yangi natijada oshadi, `BlocListener` shu bo'yicha ishlaydi.
  final int noticeId;

  Map<String, String> get fieldErrors => failure?.fieldErrors ?? const {};

  GroupsState copyWith({
    GroupsStatus? status,
    List<Group>? groups,
    bool? isSubmitting,
    Failure? failure,
    Group? savedGroup,
    String? deletedId,
    int? noticeId,
    bool clearNotice = false,
    bool clearFailure = false,
  }) {
    return GroupsState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: (clearNotice || clearFailure) ? null : (failure ?? this.failure),
      savedGroup: clearNotice ? null : (savedGroup ?? this.savedGroup),
      deletedId: clearNotice ? null : (deletedId ?? this.deletedId),
      noticeId: noticeId ?? this.noticeId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    isSubmitting,
    failure,
    savedGroup,
    deletedId,
    noticeId,
  ];
}
