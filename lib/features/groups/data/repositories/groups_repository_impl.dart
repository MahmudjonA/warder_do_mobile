import 'package:dartz/dartz.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';
import '../models/group_model.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  const GroupsRepositoryImpl(this._remote);

  final GroupsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Group>>> getGroups() =>
      guardApi(() => _remote.getGroups());

  @override
  Future<Either<Failure, Group>> createGroup({
    required String name,
    required String icon,
    required String color,
  }) =>
      guardApi(() => _remote.createGroup(name: name, icon: icon, color: color));

  @override
  Future<Either<Failure, Group>> updateGroup(
    String id, {
    String? name,
    String? icon,
    String? color,
    int? order,
  }) {
    return guardApi(
      () => _remote.updateGroup(
        id,
        GroupModel.toUpdateJson(
          name: name,
          icon: icon,
          color: color,
          order: order,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteGroup(String id) => guardApi(() async {
    await _remote.deleteGroup(id);
    return unit;
  });

  @override
  Future<Either<Failure, List<Group>>> reorderGroups(List<String> orderedIds) =>
      guardApi(() => _remote.reorderGroups(orderedIds));
}
