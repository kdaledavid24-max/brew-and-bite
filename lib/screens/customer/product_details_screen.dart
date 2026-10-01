import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

/// Product details screen with quantity selector and add to cart
class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart() {
    context.read<CartProvider>().addItem(
          widget.product,
          quantity: _quantity,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart.')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with product image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor().withValues(alpha: 0.3),
                      _getCategoryColor().withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(),
                    size: 100,
                    color: _getCategoryColor(),
                  ),
                ),
              ),
            ),
          ),
          // Product details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.orangeAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: AppColors.orangeAccent),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quantity selector
                  Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          _quantity.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Special instructions
                  Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Less sugar, please...',
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CustomButton(
            text: 'ADD TO CART • ${AppConstants.currencySymbol}${(product.price * _quantity).toStringAsFixed(0)}',
            onPressed: _addToCart,
            icon: Icons.shopping_cart_outlined,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({required IconData icon, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onTap,
        color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (widget.product.categoryId) {
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

  IconData _getCategoryIcon() {
    switch (widget.product.categoryId) {
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
