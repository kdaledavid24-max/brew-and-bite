import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

/// Admin product management screen
class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.products.isEmpty
              ? Center(
                  child: Text(
                    'No products found.',
                    style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return _buildProductTile(context, isDark, product, provider);
                  },
                ),
    );
  }

  Widget _buildProductTile(BuildContext context, bool isDark, ProductModel product, ProductProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(product.categoryId).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(product.categoryId),
            color: _getCategoryColor(product.categoryId),
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          '${AppConstants.currencySymbol}${product.price.toStringAsFixed(0)} • ${product.isAvailable ? 'Available' : 'Unavailable'}',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Availability toggle
            Switch(
              value: product.isAvailable,
              onChanged: (value) {
                final updated = product.copyWith(isAvailable: value);
                provider.updateProduct(updated);
              },
            ),
            // Edit button
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                );
              },
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _showDeleteDialog(context, isDark, product, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, bool isDark, ProductModel product, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteProduct(product.id!);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('DELETE'),
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
