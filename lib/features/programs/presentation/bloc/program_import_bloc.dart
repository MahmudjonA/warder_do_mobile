import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/program.dart';
import '../../domain/usecases/program_usecases.dart';

part 'program_import_event.dart';
part 'program_import_state.dart';

/// AI import oqimi: matn → generate → preview → save.
class ProgramImportBloc extends Bloc<ProgramImportEvent, ProgramImportState> {
  ProgramImportBloc({
    required GenerateProgram generateProgram,
    required SaveProgram saveProgram,
  }) : _generate = generateProgram,
       _save = saveProgram,
       super(const ProgramImportState()) {
    on<ProgramGenerateRequested>(_onGenerate);
    on<ProgramSaveRequested>(_onSave);
    on<ProgramImportRestarted>(
      (event, emit) => emit(const ProgramImportState()),
    );
  }

  final GenerateProgram _generate;
  final SaveProgram _save;

  Future<void> _onGenerate(
    ProgramGenerateRequested event,
    Emitter<ProgramImportState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProgramImportStatus.generating,
        clearFailure: true,
      ),
    );

    final result = await _generate(
      GenerateProgramParams(
        prompt: event.prompt,
        durationDays: event.durationDays,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: ProgramImportStatus.input, failure: failure),
      ),
      (preview) => emit(
        state.copyWith(
          status: ProgramImportStatus.preview,
          preview: preview,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onSave(
    ProgramSaveRequested event,
    Emitter<ProgramImportState> emit,
  ) async {
    final preview = state.preview;
    if (preview == null) return;

    emit(
      state.copyWith(status: ProgramImportStatus.saving, clearFailure: true),
    );

    final result = await _save(
      SaveProgramParams(
        preview: preview,
        startDate: event.startDate,
        habitTitle: event.habitTitle,
        habitIcon: event.habitIcon,
        habitColor: event.habitColor,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(status: ProgramImportStatus.preview, failure: failure),
      ),
      (_) => emit(
        state.copyWith(status: ProgramImportStatus.saved, clearFailure: true),
      ),
    );
  }
}
