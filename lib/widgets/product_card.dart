import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../screens/customer/product_details_screen.dart';

/// Aesthetic Foodpanda-style Product card with quick Add button
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.softBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image area with category gradient and rating badge
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _getCategoryColor().withValues(alpha: isDark ? 0.25 : 0.15),
                          _getCategoryColor().withValues(alpha: isDark ? 0.45 : 0.35),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(),
                        size: 48,
                        color: _getCategoryColor(),
                      ),
                    ),
                  ),
                  // Rating tag
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.midnightNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Information
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.midnightNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.electricBlue,
                          ),
                        ),
                        // Quick Foodpanda-style "+" Add button
                        InkWell(
                          onTap: () {
                            context.read<CartProvider>().addItem(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${product.name} to cart!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (product.categoryId) {
      case 1:
        return AppColors.coffeeColor;
      case 2:
        return AppColors.saladColor;
      case 3:
        return AppColors.pastaColor;
      default:
        return AppColors.electricBlue;
    }
  }

  IconData _getCategoryIcon() {
    switch (product.categoryId) {
      case 1:
        return Icons.coffee_rounded;
      case 2:
        return Icons.eco_rounded;
      case 3:
        return Icons.dinner_dining_rounded;
      default:
        return Icons.fastfood_rounded;
    }
  }
}
