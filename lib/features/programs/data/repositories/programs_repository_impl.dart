import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/program.dart';
import '../../domain/repositories/programs_repository.dart';
import '../datasources/programs_remote_data_source.dart';

class ProgramsRepositoryImpl implements ProgramsRepository {
  const ProgramsRepositoryImpl(this._remote);

  final ProgramsRemoteDataSource _remote;

  @override
  Future<Either<Failure, ProgramPreview>> generate({
    required String prompt,
    int? durationDays,
  }) {
    return _guard(
      () => _remote.generate(prompt: prompt, durationDays: durationDays),
    );
  }

  @override
  Future<Either<Failure, Unit>> save({
    required ProgramPreview preview,
    required String startDate,
    required String habitTitle,
    required String habitIcon,
    required String habitColor,
  }) {
    return _guard(() async {
      await _remote.save(
        preview: preview,
        startDate: startDate,
        habitTitle: habitTitle,
        habitIcon: habitIcon,
        habitColor: habitColor,
      );
      return unit;
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (e) {
      return Left(_mapServer(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on Exception catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Failure _mapServer(ServerException e) {
    switch (e.statusCode) {
      case 409:
        return ConflictFailure(e.message);
      case 422:
        return ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        );
      default:
        if (e.statusCode >= 500) return ServerFailure(e.message);
        return UnknownFailure(e.message);
    }
  }
}
