import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/status_tracker.dart';

/// Admin order tracking screen.
///
/// Opens from Manage Orders when the admin taps an order.
/// It shows:
///  - the SAME status timeline the customer sees
///  - the items the customer ordered
///  - the customer's contact information (name, email, phone)
///  - delivery address / instructions (for delivery orders)
///  - controls to update or cancel the order status
///
/// Saving a status here immediately updates local storage, so the
/// customer's Orders screen shows the new status.
class AdminOrderDetailsScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() =>
      _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  final OrderService _orderService = OrderService();
  final AuthService _authService = AuthService();

  OrderModel? _order;
  List<OrderItemModel> _items = [];
  UserModel? _customer;
  String _selectedStatus = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  /// Reload the order, its items, and the customer who placed it
  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      if (order != null) {
        _order = order;
        _selectedStatus = order.status;
        _items = await _orderService.getOrderItems(order.id!);
        // Look up the customer account that placed this order
        _customer = await _authService.getUserById(order.userId);
      }
    } catch (e) {
      // Keep the previous data if something went wrong
    }
    if (mounted) setState(() => _isLoading = false);
  }

  /// Status options allowed for this order type
  List<String> get _statusOptions {
    final delivery = [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusOutForDelivery,
      AppConstants.statusDelivered,
      AppConstants.statusCancelled,
    ];
    final pickup = [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusReady,
      AppConstants.statusCompleted,
      AppConstants.statusCancelled,
    ];
    return _order?.orderType == AppConstants.orderTypeDelivery
        ? delivery
        : pickup;
  }

  /// Save the chosen status to local storage (visible to the customer)
  Future<void> _saveStatus() async {
    if (_order == null || _selectedStatus == _order!.status) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _orderService.updateOrderStatus(_order!.id!, _selectedStatus);
      await _loadOrder();
      messenger.showSnackBar(
        SnackBar(content: Text('Order updated to $_selectedStatus.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not update the order. Please try again.')),
      );
    }
    if (mounted) setState(() => _isSaving = false);
  }

  /// Cancel the order in one tap
  Future<void> _cancelOrder() async {
    if (_order == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Text(
          'Order ${_order!.orderNumber} will be marked as Cancelled. '
          'The customer will see this on their Orders screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel Order',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    await _orderService.updateOrderStatus(
      _order!.id!,
      AppConstants.statusCancelled,
    );
    await _loadOrder();
    messenger.showSnackBar(
      const SnackBar(content: Text('Order has been cancelled.')),
    );
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Order')),
        body: Center(
          child: Text(
            'Order not found.',
            style: TextStyle(
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Track ${_order!.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Same timeline the customer sees
            _sectionTitle('Status Timeline', isDark),
            const SizedBox(height: 12),
            StatusTracker(status: _order!.status, orderType: _order!.orderType),
            const SizedBox(height: 24),

            // Status controls
            _sectionTitle('Update Status', isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.cream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSaving ||
                                  _selectedStatus == _order!.status
                              ? null
                              : _saveStatus,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: const Text('Save Status'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_order!.status != AppConstants.statusCancelled)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _cancelOrder,
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Order'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saving here updates the customer\'s order immediately.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer who placed the order
            _sectionTitle('Customer', isDark),
            const SizedBox(height: 12),
            _infoRow('Name', _order!.customerName, isDark),
            _infoRow('Email', _customer?.email ?? '—', isDark),
            _infoRow('Phone', _customer?.phone ?? '—', isDark),
            const SizedBox(height: 24),

            // Order information
            _sectionTitle('Order Information', isDark),
            const SizedBox(height: 12),
            _infoRow('Order Number', _order!.orderNumber, isDark),
            _infoRow(
              'Date',
              DateFormat('MMM dd, yyyy • hh:mm a').format(_order!.createdAt),
              isDark,
            ),
            _infoRow('Order Type', _order!.orderType, isDark),
            _infoRow('Payment', _order!.paymentMethod, isDark),
            if (_order!.address != null && _order!.address!.isNotEmpty)
              _infoRow('Address', _order!.address!, isDark),
            if (_order!.landmark != null && _order!.landmark!.isNotEmpty)
              _infoRow('Landmark', _order!.landmark!, isDark),
            if (_order!.deliveryInstructions != null &&
                _order!.deliveryInstructions!.isNotEmpty)
              _infoRow('Instructions', _order!.deliveryInstructions!, isDark),
            const SizedBox(height: 24),

            // Items the customer ordered
            _sectionTitle('Items Ordered', isDark),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              Text(
                'No items found for this order.',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              )
            else
              ..._items.map((item) => _itemRow(item, isDark)),
            const SizedBox(height: 24),

            // Price summary
            _sectionTitle('Price Summary', isDark),
            const SizedBox(height: 12),
            _priceRow('Subtotal', _order!.subtotal, isDark),
            _priceRow('Delivery Fee', _order!.deliveryFee, isDark),
            const Divider(),
            _priceRow('Total', _order!.total, isDark, isTotal: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
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

  Widget _itemRow(OrderItemModel item, bool isDark) {
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

  Widget _priceRow(String label, double amount, bool isDark,
      {bool isTotal = false}) {
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
