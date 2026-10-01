import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';

/// Order details screen showing complete order information and status tracker
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

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
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
      // Handle error
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
            // Status tracker
            _buildStatusTracker(isDark),
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

  Widget _buildStatusTracker(bool isDark) {
    final isDelivery = _order!.orderType == AppConstants.orderTypeDelivery;
    final statuses = isDelivery
        ? [AppConstants.statusPending, AppConstants.statusConfirmed, AppConstants.statusPreparing, AppConstants.statusOutForDelivery, AppConstants.statusDelivered]
        : [AppConstants.statusPending, AppConstants.statusConfirmed, AppConstants.statusPreparing, AppConstants.statusReady, AppConstants.statusCompleted];

    final currentIndex = statuses.indexOf(_order!.status);
    final isCancelled = _order!.status == AppConstants.statusCancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'This order has been cancelled.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < statuses.length; i++)
            _buildStatusStep(
              status: statuses[i],
              isCompleted: i <= currentIndex,
              isCurrent: i == currentIndex,
              isLast: i == statuses.length - 1,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusStep({
    required String status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required bool isDark,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and line
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                  shape: BoxShape.circle,
                  border: isCompleted
                      ? null
                      : Border.all(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.success : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted ? AppColors.success : (isDark ? AppColors.darkTextSecondary : AppColors.warmBeige),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Status text
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? (isDark ? AppColors.darkText : AppColors.lightText)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ],
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
