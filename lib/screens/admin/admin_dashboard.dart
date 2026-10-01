import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../customer/main_screen.dart';
import 'manage_products_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';
import 'sales_screen.dart';

/// Local Admin Dashboard
///
/// Reactively displays live in-memory counters directly from [OrderProvider].
/// Calculations are dynamic with 0 hardcoding.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Project Details from docx
          IconButton(
            tooltip: 'CSE101 Final Project Info',
            icon: const Icon(Icons.school_rounded, color: AppColors.skyAccent),
            onPressed: () => _showProjectInfoDialog(context, isDark),
          ),
          // Demo Role Switcher (Switch to Customer)
          IconButton(
            tooltip: 'Switch to Customer View',
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.electricBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
          // Logout
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Hero Header with dark blue styling
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.midnightNavy, AppColors.deepNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.midnightNavy.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.skyAccent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 14, color: AppColors.skyAccent),
                            SizedBox(width: 6),
                            Text(
                              'LOCAL ADMIN • IN-MEMORY STATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.skyAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.restart_alt_rounded,
                            color: Colors.white70),
                        tooltip: 'Reset Demo Orders',
                        onPressed: () {
                          orderProvider.resetToSampleData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('In-memory orders reset to initial sample set.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Brew & Bite Management',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Real-time local order tracking without internet or database.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Dynamic Statistics Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Order Counters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
                Text(
                  'Total Sales: ${AppConstants.currencySymbol}${orderProvider.totalSales.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.electricBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Statistics Cards Grid (calculated from orderProvider)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildStatCard(
                  title: "Total Orders",
                  value: orderProvider.totalOrders.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.electricBlue,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: "Pending",
                  value: orderProvider.pendingOrders.toString(),
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  isDark: isDark,
                  isAlert: orderProvider.pendingOrders > 0,
                ),
                _buildStatCard(
                  title: "Preparing",
                  value: orderProvider.preparingOrders.toString(),
                  icon: Icons.soup_kitchen_rounded,
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: "Completed",
                  value: orderProvider.completedOrders.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: "Cancelled",
                  value: orderProvider.cancelledOrders.toString(),
                  icon: Icons.cancel_rounded,
                  color: AppColors.error,
                  isDark: isDark,
                ),
                _buildStatCard(
                  title: "Completed Sales",
                  value:
                      '${AppConstants.currencySymbol}${orderProvider.totalSales.toStringAsFixed(0)}',
                  icon: Icons.payments_rounded,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 26),

            // Quick Actions Section
            Text(
              'Management & Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.midnightNavy,
              ),
            ),
            const SizedBox(height: 12),

            // Action 1: Manage Orders (PRIMARY)
            _buildActionCard(
              context,
              isDark,
              title: 'Live Order Management',
              subtitle:
                  'View all orders, change order status & notify customer',
              icon: Icons.receipt_long_rounded,
              color: AppColors.electricBlue,
              badge: orderProvider.totalOrders > 0
                  ? '${orderProvider.totalOrders} Orders'
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageOrdersScreen()),
                );
              },
            ),

            // Action 2: Manage Menu Products
            _buildActionCard(
              context,
              isDark,
              title: 'Product Catalog',
              subtitle: 'Add, update price, or toggle menu availability',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFF0284C7),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageProductsScreen()),
                );
              },
            ),

            // Action 3: Customer Accounts
            _buildActionCard(
              context,
              isDark,
              title: 'Customer Directory',
              subtitle: 'View registered local customer profiles & addresses',
              icon: Icons.people_alt_rounded,
              color: AppColors.orangeAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ManageUsersScreen()),
                );
              },
            ),

            // Action 4: Sales Analytics
            _buildActionCard(
              context,
              isDark,
              title: 'Sales & Analytics',
              subtitle: 'Status breakdown & revenue summary reports',
              icon: Icons.analytics_rounded,
              color: AppColors.success,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SalesScreen()),
                );
              },
            ),

            // Action 5: Demo Switcher
            _buildActionCard(
              context,
              isDark,
              title: 'Customer Storefront Mode',
              subtitle: 'Switch role to customer to place orders and track live',
              icon: Icons.shopping_bag_rounded,
              color: const Color(0xFFEC4899),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAlert
              ? color.withValues(alpha: 0.5)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.softBorder),
          width: isAlert ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isAlert)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
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
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? AppColors.darkText : AppColors.midnightNavy,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showProjectInfoDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: AppColors.electricBlue),
            SizedBox(width: 10),
            Text('CSE101 Final Project'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Food Ordering App (Project #4)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Assigned Group Members:'),
            const SizedBox(height: 4),
            const Text('• Kristian Dale\n• Stephanie\n• Melea',
                style: TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
            const Divider(height: 24),
            const Text('Architecture & Compliance:'),
            const SizedBox(height: 4),
            const Text(
              '✓ 100% Local In-Memory State Management\n'
              '✓ Shared OrderProvider (ChangeNotifier)\n'
              '✓ Zero Database, Zero Firebase, Zero REST API\n'
              '✓ Real-time status sync between Customer & Admin\n'
              '✓ Forms with validation & responsive layouts',
              style: TextStyle(fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
