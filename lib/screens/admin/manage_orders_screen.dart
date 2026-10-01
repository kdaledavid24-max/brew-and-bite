import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

/// Admin order management screen
class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      _orders = await _orderService.getAllOrders();
    } catch (e) {
      // Handle error
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<String> _getStatusesForOrder(OrderModel order) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    'No orders found.',
                    style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(context, isDark, order);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(BuildContext context, bool isDark, OrderModel order) {
    final statuses = _getStatusesForOrder(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                  ),
                ),
                Text(
                  '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.customerName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.orderType} • ${order.paymentMethod}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Status dropdown
            Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: order.status,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newStatus) async {
                      if (newStatus != null && newStatus != order.status) {
                        final messenger = ScaffoldMessenger.of(context);
                        await _orderService.updateOrderStatus(order.id!, newStatus);
                        _loadOrders();
                        messenger.showSnackBar(
                          SnackBar(content: Text('Order status updated to $newStatus.')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return AppColors.warning;
      case AppConstants.statusConfirmed:
        return AppColors.info;
      case AppConstants.statusPreparing:
        return AppColors.orangeAccent;
      case AppConstants.statusReady:
      case AppConstants.statusOutForDelivery:
        return AppColors.success;
      case AppConstants.statusCompleted:
      case AppConstants.statusDelivered:
        return AppColors.success;
      case AppConstants.statusCancelled:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
