import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/error_mapper.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel> createGroup({
    required String name,
    required String icon,
    required String color,
  });
  Future<GroupModel> updateGroup(String id, Map<String, dynamic> changes);
  Future<void> deleteGroup(String id);
  Future<List<GroupModel>> reorderGroups(List<String> orderedIds);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  const GroupsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      // Server `order` bo'yicha saralab beradi — qayta saralash shart emas.
      final response = await _dio.get<List<dynamic>>(ApiConstants.groups);
      return response.data!
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<GroupModel> createGroup({
    required String name,
    required String icon,
    required String color,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.groups,
        data: GroupModel.toCreateJson(name: name, icon: icon, color: color),
      );
      return GroupModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<GroupModel> updateGroup(
    String id,
    Map<String, dynamic> changes,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        ApiConstants.group(id),
        data: changes,
      );
      return GroupModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    try {
      // Odatlar o'chmaydi — ular guruhsiz bo'lib qoladi.
      await _dio.delete<void>(ApiConstants.group(id));
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<List<GroupModel>> reorderGroups(List<String> orderedIds) async {
    try {
      final response = await _dio.post<List<dynamic>>(
        ApiConstants.groupsReorder,
        data: GroupModel.toReorderJson(orderedIds),
      );
      return response.data!
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
