import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';
import 'sales_screen.dart';

/// Admin dashboard with statistics and quick access to management screens
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      _stats = await _orderService.getDashboardStats();
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome
                    Text(
                      'Welcome, Admin!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here\'s what\'s happening today.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Today\'s Orders',
                          _stats['todayOrders']?.toString() ?? '0',
                          Icons.shopping_bag_outlined,
                          AppColors.coffeeBrown,
                          isDark,
                        ),
                        _buildStatCard(
                          'Today\'s Sales',
                          '${AppConstants.currencySymbol}${_stats['todaySales']?.toStringAsFixed(0) ?? '0'}',
                          Icons.payments_outlined,
                          AppColors.success,
                          isDark,
                        ),
                        _buildStatCard(
                          'Products',
                          _stats['totalProducts']?.toString() ?? '0',
                          Icons.inventory_2_outlined,
                          AppColors.info,
                          isDark,
                        ),
                        _buildStatCard(
                          'Customers',
                          _stats['totalCustomers']?.toString() ?? '0',
                          Icons.people_outlined,
                          AppColors.orangeAccent,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionCard(
                      context,
                      isDark,
                      title: 'Manage Products',
                      subtitle: 'Add, edit, or remove products',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.coffeeBrown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageProductsScreen()),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      isDark,
                      title: 'Manage Orders',
                      subtitle: 'View and update order status',
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.info,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageOrdersScreen()),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      isDark,
                      title: 'Manage Customers',
                      subtitle: 'View customer information',
                      icon: Icons.people_outlined,
                      color: AppColors.orangeAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      isDark,
                      title: 'Sales Report',
                      subtitle: 'View sales and order analytics',
                      icon: Icons.analytics_outlined,
                      color: AppColors.success,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SalesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
