/// Category model for product categories (Coffee, Salad, Pasta)
class CategoryModel {
  final int? id;
  final String name;
  final String description;
  final String icon; // Icon identifier

  CategoryModel({
    this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      icon: map['icon'] as String,
    );
  }
}
