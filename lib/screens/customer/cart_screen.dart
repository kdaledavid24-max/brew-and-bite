import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'checkout_screen.dart';

/// Cart screen showing all items in the shopping cart
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context, isDark)
          : Column(
              children: [
                // Cart items list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _buildCartItem(context, isDark, item, cart);
                    },
                  ),
                ),
                // Order summary
                _buildOrderSummary(context, isDark, cart),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add something delicious\nfrom our menu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'BROWSE MENU',
            onPressed: () {
              // Navigate to home tab
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, bool isDark, CartItemModel item, CartProvider cart) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.product.categoryId).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(item.product.categoryId),
                color: _getCategoryColor(item.product.categoryId),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppConstants.currencySymbol}${item.product.price.toStringAsFixed(0)} each',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Decrease button
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: () => cart.decreaseQuantity(item.product.id!),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.quantity.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),
                      // Increase button
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: () => cart.increaseQuantity(item.product.id!),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price and remove
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => cart.removeItem(item.product.id!),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.coffeeBrown.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.coffeeBrown),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDark, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${cart.subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${AppConstants.deliveryFee.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${(cart.subtotal + AppConstants.deliveryFee).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'CHECKOUT',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1:
        return AppColors.coffeeColor;
      case 2:
        return AppColors.saladColor;
      case 3:
        return AppColors.pastaColor;
      default:
        return AppColors.coffeeBrown;
    }
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.coffee;
      case 2:
        return Icons.eco;
      case 3:
        return Icons.dinner_dining;
      default:
        return Icons.fastfood;
    }
  }
}
