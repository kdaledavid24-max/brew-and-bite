import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

/// Cart provider - manages shopping cart state
class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  /// Total number of items in cart
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal (before delivery fee)
  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);

  /// Whether the cart is empty
  bool get isEmpty => _items.isEmpty;

  /// Add a product to cart
  void addItem(ProductModel product, {int quantity = 1, String? notes}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      // Product already in cart - increase quantity
      _items[existingIndex].quantity += quantity;
    } else {
      // New product - add to cart
      _items.add(CartItemModel(product: product, quantity: quantity, notes: notes));
    }
    notifyListeners();
  }

  /// Increase item quantity
  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrease item quantity (removes if quantity becomes 0)
  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  /// Update item notes
  void updateNotes(int productId, String notes) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].notes = notes;
      notifyListeners();
    }
  }

  /// Clear entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
