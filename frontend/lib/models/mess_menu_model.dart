// frontend/lib/models/mess_menu_model.dart
class MessMenuModel {
  final int id;
  final String dayOfWeek;
  final String mealType;
  final String menuItem;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessMenuModel({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.menuItem,
    this.createdAt,
    this.updatedAt,
  });

  factory MessMenuModel.fromJson(Map<String, dynamic> json) {
    return MessMenuModel(
      id: json['id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? '',
      mealType: json['meal_type'] ?? '',
      menuItem: json['menu_item'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'meal_type': mealType,
      'menu_item': menuItem,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
