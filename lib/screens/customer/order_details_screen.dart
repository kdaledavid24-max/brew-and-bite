import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_tracker.dart';

/// Customer Order Details & Real-Time Tracking Screen
///
/// Reactively watches [OrderProvider]. When the Admin changes the order
/// status from the Admin Dashboard, this screen immediately updates
/// its timeline and notification badge in real time!
class OrderDetailsScreen extends StatelessWidget {
  final dynamic orderId; // String or int
  final String? orderNumber;

  const OrderDetailsScreen({
    super.key,
    this.orderId,
    this.orderNumber,
  });

  String _lookupKey() {
    if (orderNumber != null && orderNumber!.isNotEmpty) {
      return orderNumber!;
    }
    return orderId?.toString() ?? 'ORD-001';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = context.watch<OrderProvider>();
    final key = _lookupKey();
    final order = orderProvider.getOrderById(key);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Order "$key" not found.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'It may have been cleared or not placed yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Orders'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final statusColor = AppColors.getStatusColor(order.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ORDER #${order.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            tooltip: 'Live In-Memory Tracking Active',
            icon: const Icon(Icons.bolt_rounded, color: AppColors.electricBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Real-Time In-Memory State Active. Status updates from Admin appear immediately!',
                  ),
                  duration: Duration(seconds: 2),
                ),
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
            // Foodpanda aesthetic status announcement banner
            _buildStatusHeroBanner(context, order, statusColor, isDark),
            const SizedBox(height: 20),

            // Live Stepper Tracker
            _buildSectionHeader('Order Progress', isDark),
            const SizedBox(height: 12),
            StatusTracker(
              status: order.status,
              orderType: order.orderType,
            ),
            const SizedBox(height: 24),

            // Order info card
            _buildSectionHeader('Order Information', isDark),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              isDark,
              children: [
                _buildInfoRow('Order Number', order.orderNumber, isDark, isHighlight: true),
                _buildInfoRow('Placed On',
                    DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt), isDark),
                _buildInfoRow('Customer', order.customerName, isDark),
                _buildInfoRow('Contact Phone', order.customerPhone, isDark),
                _buildInfoRow('Fulfillment', order.orderType, isDark),
                _buildInfoRow('Payment Method', order.paymentMethod, isDark),
                if (order.address.isNotEmpty)
                  _buildInfoRow('Address', order.address, isDark),
                if (order.landmark != null && order.landmark!.isNotEmpty)
                  _buildInfoRow('Landmark', order.landmark!, isDark),
                if (order.deliveryInstructions != null &&
                    order.deliveryInstructions!.isNotEmpty)
                  _buildInfoRow('Instructions', order.deliveryInstructions!, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Ordered items breakdown
            _buildSectionHeader('Items Ordered (${order.items.length})', isDark),
            const SizedBox(height: 12),
            _buildItemsCard(context, order, isDark),
            const SizedBox(height: 24),

            // Price summary
            _buildSectionHeader('Price Breakdown', isDark),
            const SizedBox(height: 12),
            _buildPriceSummaryCard(context, order, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeroBanner(
      BuildContext context, Order order, Color statusColor, bool isDark) {
    String message;
    switch (order.status.toLowerCase()) {
      case 'pending':
        message = 'Your order is placed! Café is reviewing your order.';
        break;
      case 'confirmed':
        message = 'Your order has been confirmed by the café!';
        break;
      case 'preparing':
        message = 'Your order is now being freshly prepared!';
        break;
      case 'ready':
        message = 'Your order is ready! Pick it up at the counter.';
        break;
      case 'out for delivery':
        message = 'Your rider is on the way to your address!';
        break;
      case 'completed':
        message = 'Order completed! Thank you for dining with Brew & Bite.';
        break;
      case 'delivered':
        message = 'Order delivered! Enjoy your delicious meal.';
        break;
      case 'cancelled':
        message = 'This order was cancelled.';
        break;
      default:
        message = 'Status: ${order.status}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withValues(alpha: isDark ? 0.25 : 0.15),
            statusColor.withValues(alpha: isDark ? 0.10 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppColors.getStatusIcon(order.status),
              color: statusColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Tracking',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkText : AppColors.midnightNavy,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, bool isDark,
      {required List<Widget> children}) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight
                    ? AppColors.electricBlue
                    : (isDark ? AppColors.darkText : AppColors.midnightNavy),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, Order order, bool isDark) {
    return Container(
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
        children: order.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.electricBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.product.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.midnightNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummaryCard(
      BuildContext context, Order order, bool isDark) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${order.subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                order.deliveryFee > 0
                    ? '${AppConstants.currencySymbol}${order.deliveryFee.toStringAsFixed(0)}'
                    : 'Free',
                style: TextStyle(
                  fontSize: 14,
                  color: order.deliveryFee > 0
                      ? (isDark ? AppColors.darkText : AppColors.midnightNavy)
                      : AppColors.success,
                  fontWeight: order.deliveryFee > 0
                      ? FontWeight.normal
                      : FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
