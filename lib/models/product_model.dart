/// Product model representing a menu item
class ProductModel {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final double rating;
  final bool isAvailable;
  final DateTime createdAt;

  ProductModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.rating = 0.0,
    this.isAvailable = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'rating': rating,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imagePath: map['image_path'] as String,
      rating: (map['rating'] as num).toDouble(),
      isAvailable: (map['is_available'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  ProductModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    String? imagePath,
    double? rating,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
