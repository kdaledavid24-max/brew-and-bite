import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../screens/customer/product_details_screen.dart';

/// Product card widget for displaying products in a grid
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
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
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
                    size: 48,
                    color: _getCategoryColor(),
                  ),
                ),
              ),
            ),
            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: AppColors.orangeAccent),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
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
    // Determine color based on category ID
    switch (product.categoryId) {
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
    switch (product.categoryId) {
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
