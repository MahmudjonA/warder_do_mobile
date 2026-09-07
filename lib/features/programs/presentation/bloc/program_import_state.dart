part of 'program_import_bloc.dart';

enum ProgramImportStatus { input, generating, preview, saving, saved }

class ProgramImportState extends Equatable {
  const ProgramImportState({
    this.status = ProgramImportStatus.input,
    this.preview,
    this.failure,
  });

  final ProgramImportStatus status;
  final ProgramPreview? preview;
  final Failure? failure;

  ProgramImportState copyWith({
    ProgramImportStatus? status,
    ProgramPreview? preview,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProgramImportState(
      status: status ?? this.status,
      preview: preview ?? this.preview,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, preview, failure];
}
