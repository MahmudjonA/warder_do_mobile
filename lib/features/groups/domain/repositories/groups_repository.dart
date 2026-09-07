import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/group.dart';

abstract class GroupsRepository {
  Future<Either<Failure, List<Group>>> getGroups();

  Future<Either<Failure, Group>> createGroup({
    required String name,
    required String icon,
    required String color,
  });

  Future<Either<Failure, Group>> updateGroup(
    String id, {
    String? name,
    String? icon,
    String? color,
    int? order,
  });

  /// Guruh o'chsa **odatlar o'chmaydi** — ular guruhsiz bo'lib qoladi.
  Future<Either<Failure, Unit>> deleteGroup(String id);

  /// Drag-and-drop tugagach chaqiriladi. Biror id xato bo'lsa hech biri
  /// saqlanmaydi — ya'ni yarim-yorti tartib bo'lmaydi.
  Future<Either<Failure, List<Group>>> reorderGroups(List<String> orderedIds);
}
