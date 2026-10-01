import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../admin/admin_dashboard.dart';
import 'category_screen.dart';

/// Customer home screen with greeting, search, categories, and featured products
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => productProvider.loadProducts(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, ${auth.currentUser?.name.split(' ').first ?? 'Customer'}!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'What would you like today?',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Switch to Admin Dashboard',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AdminDashboard()),
                            );
                          },
                          icon: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.electricBlue,
                          ),
                        ),
                        // Dark mode toggle
                        IconButton(
                          onPressed: () {
                            context.read<ThemeProvider>().toggleTheme();
                          },
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    productProvider.search(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search coffee, pasta, salad...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              productProvider.search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),
                // Promotional banner
                _buildPromoBanner(context, isDark),
                const SizedBox(height: 24),
                // Categories section
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategories(context, isDark, productProvider),
                const SizedBox(height: 24),
                // Featured products
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchController.text.isNotEmpty ? 'Search Results' : 'Featured Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    if (_searchController.text.isEmpty)
                      TextButton(
                        onPressed: () {
                          // Navigate to categories tab
                        },
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProductGrid(context, isDark, productProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.goldAccent.withValues(alpha: 0.3), AppColors.orangeAccent.withValues(alpha: 0.2)]
              : [AppColors.coffeeBrown, AppColors.goldAccent],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPECIAL OFFER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.goldAccent : Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '20% OFF',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selected Coffee',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppColors.darkText : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to coffee category
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              foregroundColor: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Order Now →'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, bool isDark, ProductProvider provider) {
    if (provider.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final icons = [Icons.coffee, Icons.eco, Icons.dinner_dining];
    final colors = [AppColors.coffeeColor, AppColors.saladColor, AppColors.pastaColor];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          return Padding(
            padding: EdgeInsets.only(right: index < provider.categories.length - 1 ? 12 : 0),
            child: CategoryCard(
              name: category.name,
              icon: icons[index % icons.length],
              color: colors[index % colors.length],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(categoryId: category.id!, categoryName: category.name),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isDark, ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final products = provider.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            const SizedBox(height: 12),
            Text(
              'No products found.',
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try another search.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
