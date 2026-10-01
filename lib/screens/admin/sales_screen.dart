import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

/// Admin sales and analytics screen
/// Dynamically computed from in-memory [OrderProvider]
class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = context.watch<OrderProvider>();

    final totalOrders = orderProvider.totalOrders;
    final completedOrders = orderProvider.completedOrders;
    final cancelledOrders = orderProvider.cancelledOrders;
    final activeOrders = (totalOrders - completedOrders - cancelledOrders).clamp(0, 1000);
    final totalSales = orderProvider.totalSales;
    final todayOrders = orderProvider.todayOrdersCount;
    final todaySales = orderProvider.todaySales;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Order Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildStatCard(
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.receipt_long_rounded,
                  AppColors.electricBlue,
                  isDark,
                ),
                _buildStatCard(
                  'Completed Orders',
                  completedOrders.toString(),
                  Icons.check_circle_rounded,
                  AppColors.success,
                  isDark,
                ),
                _buildStatCard(
                  'Cancelled',
                  cancelledOrders.toString(),
                  Icons.cancel_rounded,
                  AppColors.error,
                  isDark,
                ),
                _buildStatCard(
                  'Total Sales',
                  '${AppConstants.currencySymbol}${totalSales.toStringAsFixed(0)}',
                  Icons.payments_rounded,
                  AppColors.success,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's summary
            Text(
              "Today's Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.midnightNavy,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.softBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Orders Today',
                    '$todayOrders orders',
                    isDark,
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Sales Today (Completed Only)',
                    '${AppConstants.currencySymbol}${todaySales.toStringAsFixed(0)}',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Status Breakdown Bar
            Text(
              'Order Status Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.midnightNavy,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.softBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildStatusBar(
                    'Completed',
                    completedOrders,
                    totalOrders > 0 ? totalOrders : 1,
                    AppColors.success,
                    isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildStatusBar(
                    'Active / In Progress',
                    activeOrders,
                    totalOrders > 0 ? totalOrders : 1,
                    AppColors.electricBlue,
                    isDark,
                  ),
                  const SizedBox(height: 14),
                  _buildStatusBar(
                    'Cancelled',
                    cancelledOrders,
                    totalOrders > 0 ? totalOrders : 1,
                    AppColors.error,
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
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

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.midnightNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBar(
      String label, int count, int total, Color color, bool isDark) {
    final percentage = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.midnightNavy,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}% ($count orders)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.softIce,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
