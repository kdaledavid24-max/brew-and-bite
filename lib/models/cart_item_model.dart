import 'product_model.dart';

/// Cart item model representing a product in the shopping cart
class CartItemModel {
  final ProductModel product;
  int quantity;
  String? notes;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.notes,
  });

  /// Calculate subtotal for this cart item
  double get subtotal => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'product_price': product.price,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      product: ProductModel(
        id: map['product_id'] as int?,
        categoryId: 1,
        name: map['product_name'] as String? ?? 'Item',
        description: '',
        price: (map['product_price'] as num?)?.toDouble() ?? 0.0,
        imagePath: '',
        createdAt: DateTime.now(),
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      notes: map['notes'] as String?,
    );
  }
}

/// Alias for CartItem to support both conventions
typedef CartItem = CartItemModel;
