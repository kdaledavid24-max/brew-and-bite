import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_tracker.dart';

/// Order details screen showing complete order information and status tracker.
///
/// Auto-refreshes every few seconds so the timeline advances live when
/// the admin updates the order status.
class OrderDetailsScreen extends StatefulWidget {
  final int? orderId;
  final String? orderNumber;

  const OrderDetailsScreen({super.key, this.orderId, this.orderNumber});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  OrderModel? _order;
  List<OrderItemModel> _items = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrder();

    // Auto-refresh so the status tracker moves when the admin updates it
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _loadOrder(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Reload this order and its items.
  /// [silent] = refresh in the background without showing the spinner.
  Future<void> _loadOrder({bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);
    try {
      OrderModel? order;
      if (widget.orderId != null) {
        order = await _orderService.getOrderById(widget.orderId!);
      } else if (widget.orderNumber != null) {
        // Find order by number - need to get all orders and find matching
        final allOrders = await _orderService.getAllOrders();
        order = allOrders.firstWhere(
          (o) => o.orderNumber == widget.orderNumber,
          orElse: () => throw Exception('Order not found'),
        );
      }

      if (order != null) {
        _order = order;
        _items = await _orderService.getOrderItems(order.id!);
      }
    } catch (e) {
      // Keep the previous data if loading fails
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Text(
            'Order not found.',
            style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order!.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status tracker (shared widget - same view the admin sees)
            StatusTracker(
              status: _order!.status,
              orderType: _order!.orderType,
            ),
            const SizedBox(height: 24),

            // Order info
            _buildSectionTitle('Order Information', isDark),
            const SizedBox(height: 12),
            _buildInfoRow('Order Number', _order!.orderNumber, isDark),
            _buildInfoRow('Date', DateFormat('MMM dd, yyyy • hh:mm a').format(_order!.createdAt), isDark),
            _buildInfoRow('Order Type', _order!.orderType, isDark),
            _buildInfoRow('Payment Method', _order!.paymentMethod, isDark),
            if (_order!.address != null)
              _buildInfoRow('Address', _order!.address!, isDark),
            const SizedBox(height: 24),

            // Order items
            _buildSectionTitle('Items', isDark),
            const SizedBox(height: 12),
            ..._items.map((item) => _buildOrderItem(item, isDark)),
            const SizedBox(height: 24),

            // Price summary
            _buildSectionTitle('Price Summary', isDark),
            const SizedBox(height: 12),
            _buildPriceRow('Subtotal', _order!.subtotal, isDark),
            _buildPriceRow('Delivery Fee', _order!.deliveryFee, isDark),
            const Divider(),
            _buildPriceRow('Total', _order!.total, isDark, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.productName} x${item.quantity}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          Text(
            '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, bool isDark, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          Text(
            '${AppConstants.currencySymbol}${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
        ],
      ),
    );
  }
}
