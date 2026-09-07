import '../../domain/entities/group.dart';

class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.order,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String? ?? 'folder',
      color: json['color'] as String? ?? '#6C7BF5',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  /// `POST /groups`. `order` yuborilmasa server oxiriga qo'shadi.
  static Map<String, dynamic> toCreateJson({
    required String name,
    required String icon,
    required String color,
  }) {
    return {'name': name, 'icon': icon, 'color': color};
  }

  /// `PATCH /groups/{id}` — faqat berilgan maydonlar.
  static Map<String, dynamic> toUpdateJson({
    String? name,
    String? icon,
    String? color,
    int? order,
  }) {
    return {'name': ?name, 'icon': ?icon, 'color': ?color, 'order': ?order};
  }

  /// Reorder body — **massiv**.
  static List<Map<String, dynamic>> toReorderJson(List<String> orderedIds) => [
    for (var i = 0; i < orderedIds.length; i++)
      {'id': orderedIds[i], 'order': i},
  ];
}
