import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/product_card.dart';

/// Category screen showing products filtered by category
class CategoryScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const CategoryScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadProducts();
      if (widget.categoryId != null) {
        provider.filterByCategory(widget.categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Categories'),
        leading: widget.categoryId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Column(
        children: [
          // Category filter chips
          if (widget.categoryId == null)
            _buildCategoryChips(context, isDark, provider),
          // Product grid
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredProducts.isEmpty
                    ? _buildEmptyState(context, isDark)
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: provider.filteredProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: provider.filteredProducts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, bool isDark, ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: provider.selectedCategoryId == null,
                onSelected: (selected) {
                  provider.filterByCategory(null);
                },
                selectedColor: isDark ? AppColors.goldAccent.withValues(alpha: 0.3) : AppColors.coffeeBrown.withValues(alpha: 0.2),
              ),
            ),
            ...provider.categories.map((category) {
              final isSelected = provider.selectedCategoryId == category.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    provider.filterByCategory(category.id);
                  },
                  selectedColor: isDark ? AppColors.goldAccent.withValues(alpha: 0.3) : AppColors.coffeeBrown.withValues(alpha: 0.2),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another category.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
