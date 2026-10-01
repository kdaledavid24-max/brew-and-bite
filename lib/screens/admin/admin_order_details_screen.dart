import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_tracker.dart';

/// Admin Order Details & Status Management Screen
///
/// Directly modifies status via [OrderProvider]. When updated,
/// the customer's Order Tracking screen rebuilds in real-time.
class AdminOrderDetailsScreen extends StatelessWidget {
  final dynamic orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  List<String> _getAvailableStatuses(Order order) {
    if (order.orderType == AppConstants.orderTypeDelivery) {
      return [
        AppConstants.statusPending,
        AppConstants.statusConfirmed,
        AppConstants.statusPreparing,
        AppConstants.statusOutForDelivery,
        AppConstants.statusDelivered,
        AppConstants.statusCancelled,
      ];
    }
    return [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusReady,
      AppConstants.statusCompleted,
      AppConstants.statusCancelled,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.getOrderById(orderId.toString());

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Text(
            'Order #$orderId not found in local memory.',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.midnightNavy,
            ),
          ),
        ),
      );
    }

    final statusColor = AppColors.getStatusColor(order.status);
    final statusOptions = _getAvailableStatuses(order);

    return Scaffold(
      appBar: AppBar(
        title: Text('ORDER #${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Control Card (Primary Admin Action)
            _buildStatusControlCard(
              context,
              order,
              orderProvider,
              statusOptions,
              statusColor,
              isDark,
            ),
            const SizedBox(height: 24),

            // Live Shared Status Timeline
            _buildSectionHeader('Live Timeline (Customer Sync)', isDark),
            const SizedBox(height: 12),
            StatusTracker(
              status: order.status,
              orderType: order.orderType,
            ),
            const SizedBox(height: 24),

            // Customer Details Card
            _buildSectionHeader('Customer Information', isDark),
            const SizedBox(height: 12),
            _buildCard(
              context,
              isDark,
              children: [
                _buildInfoRow('Customer Name', order.customerName, isDark, isBold: true),
                _buildInfoRow('Order Date', DateFormat('MMMM dd, yyyy • hh:mm a').format(order.createdAt), isDark),
                _buildInfoRow('Phone', order.customerPhone, isDark),
                _buildInfoRow('Order Type', order.orderType, isDark),
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

            // Ordered Items
            _buildSectionHeader('Items Ordered (${order.items.length})', isDark),
            const SizedBox(height: 12),
            _buildItemsCard(context, order, isDark),
            const SizedBox(height: 24),

            // Price Summary
            _buildSectionHeader('Payment Summary', isDark),
            const SizedBox(height: 12),
            _buildPriceSummary(context, order, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusControlCard(
    BuildContext context,
    Order order,
    OrderProvider orderProvider,
    List<String> statusOptions,
    Color statusColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppColors.getStatusIcon(order.status),
                  color: statusColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          Text(
            'Change Status (Customer views update immediately):',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.midnightNavy,
            ),
          ),
          const SizedBox(height: 10),

          // Dropdown status selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.softIce,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : AppColors.softBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusOptions.contains(order.status)
                    ? order.status
                    : statusOptions.first,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                items: statusOptions.map((st) {
                  return DropdownMenuItem(
                    value: st,
                    child: Text(
                      st,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getStatusColor(st),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != order.status) {
                    orderProvider.updateOrderStatus(order.id, newStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Order ${order.orderNumber} updated to "$newStatus"!',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Quick Action Status Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statusOptions.map((st) {
              final isCurrent = st == order.status;
              final col = AppColors.getStatusColor(st);
              return InkWell(
                onTap: isCurrent
                    ? null
                    : () {
                        orderProvider.updateOrderStatus(order.id, st);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order ${order.orderNumber} updated to "$st"!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: isCurrent ? col : col.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent ? col : col.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    st,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : col,
                    ),
                  ),
                ),
              );
            }).toList(),
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

  Widget _buildCard(BuildContext context, bool isDark,
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
      {bool isBold = false}) {
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
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.midnightNavy,
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

  Widget _buildPriceSummary(BuildContext context, Order order, bool isDark) {
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
