import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

/// Admin sales and analytics screen
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
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
        title: const Text('Sales Report'),
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
                    // Overview cards
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Total Orders',
                          _stats['totalOrders']?.toString() ?? '0',
                          Icons.shopping_bag_outlined,
                          AppColors.coffeeBrown,
                          isDark,
                        ),
                        _buildStatCard(
                          'Completed',
                          _stats['completedOrders']?.toString() ?? '0',
                          Icons.check_circle_outline,
                          AppColors.success,
                          isDark,
                        ),
                        _buildStatCard(
                          'Cancelled',
                          _stats['cancelledOrders']?.toString() ?? '0',
                          Icons.cancel_outlined,
                          AppColors.error,
                          isDark,
                        ),
                        _buildStatCard(
                          'Total Sales',
                          '${AppConstants.currencySymbol}${_stats['totalSales']?.toStringAsFixed(0) ?? '0'}',
                          Icons.payments_outlined,
                          AppColors.orangeAccent,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Today's summary
                    Text(
                      'Today\'s Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Orders Today',
                              _stats['todayOrders']?.toString() ?? '0',
                              isDark,
                            ),
                            const Divider(),
                            _buildSummaryRow(
                              'Sales Today',
                              '${AppConstants.currencySymbol}${_stats['todaySales']?.toStringAsFixed(0) ?? '0'}',
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Simple bar chart representation
                    Text(
                      'Order Status Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatusBar(
                      'Completed',
                      _stats['completedOrders']?.toInt() ?? 0,
                      _stats['totalOrders']?.toInt() ?? 1,
                      AppColors.success,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBar(
                      'Cancelled',
                      _stats['cancelledOrders']?.toInt() ?? 0,
                      _stats['totalOrders']?.toInt() ?? 1,
                      AppColors.error,
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBar(
                      'Active',
                      ((_stats['totalOrders']?.toInt() ?? 0) -
                              (_stats['completedOrders']?.toInt() ?? 0) -
                              (_stats['cancelledOrders']?.toInt() ?? 0))
                          .clamp(0, 1000),
                      _stats['totalOrders']?.toInt() ?? 1,
                      AppColors.info,
                      isDark,
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

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color, bool isDark) {
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
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            Text(
              '$count orders',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.cream,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
