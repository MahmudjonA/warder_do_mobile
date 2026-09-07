import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/group.dart';
import '../repositories/groups_repository.dart';

/// Guruhlar bo'yicha use case'lar.

class GetGroups implements UseCase<List<Group>, NoParams> {
  const GetGroups(this._repository);

  final GroupsRepository _repository;

  @override
  Future<Either<Failure, List<Group>>> call(NoParams params) =>
      _repository.getGroups();
}

/// Guruhni yaratadi yoki yangilaydi.
///
/// Bitta use case bo'lishining sababi: forma ekrani ikkala holatda ham bir xil,
/// farqi faqat [SaveGroupParams.id] borligida.
class SaveGroup implements UseCase<Group, SaveGroupParams> {
  const SaveGroup(this._repository);

  final GroupsRepository _repository;

  @override
  Future<Either<Failure, Group>> call(SaveGroupParams params) {
    final id = params.id;
    if (id == null) {
      return _repository.createGroup(
        name: params.name,
        icon: params.icon,
        color: params.color,
      );
    }
    return _repository.updateGroup(
      id,
      name: params.name,
      icon: params.icon,
      color: params.color,
    );
  }
}

class SaveGroupParams extends Equatable {
  const SaveGroupParams({
    required this.name,
    required this.icon,
    required this.color,
    this.id,
  });

  /// `null` — yangi guruh.
  final String? id;

  final String name;
  final String icon;
  final String color;

  @override
  List<Object?> get props => [id, name, icon, color];
}

/// Guruhni o'chiradi. Ichidagi odatlar o'chmaydi — guruhsiz bo'lib qoladi.
class DeleteGroup implements UseCase<Unit, String> {
  const DeleteGroup(this._repository);

  final GroupsRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String params) =>
      _repository.deleteGroup(params);
}

/// Drag-and-drop tugagach chaqiriladi.
class ReorderGroups implements UseCase<List<Group>, List<String>> {
  const ReorderGroups(this._repository);

  final GroupsRepository _repository;

  @override
  Future<Either<Failure, List<Group>>> call(List<String> params) =>
      _repository.reorderGroups(params);
}
