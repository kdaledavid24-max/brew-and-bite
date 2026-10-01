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
      'quantity': quantity,
      'notes': notes,
    };
  }
}
