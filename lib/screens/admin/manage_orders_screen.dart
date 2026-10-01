import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import 'admin_order_details_screen.dart';

/// Admin order management screen.
///
/// Lists every customer order stored on this device. For each order the
/// admin can:
///  - tap the card to open the full tracking screen (items, customer,
///    timeline, status controls), or
///  - use the quick status dropdown to update it right here.
///
/// Both actions write to local storage, so the customer's Orders screen
/// shows the new status right away.
class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];

  /// Items for each order, keyed by order ID (used for the card summary)
  Map<int, List<OrderItemModel>> _itemsByOrder = {};
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

      // Load the items of every order so we can show what was ordered
      final itemsByOrder = <int, List<OrderItemModel>>{};
      for (final order in _orders) {
        itemsByOrder[order.id!] = await _orderService.getOrderItems(order.id!);
      }
      _itemsByOrder = itemsByOrder;
    } catch (e) {
      // Keep the previous list if loading fails
    }
    if (mounted) setState(() => _isLoading = false);
  }

  /// Status options for an order (differs for pickup vs delivery)
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

  /// "Biscoff Latte x2, Chicken Salad x1"
  String _itemsSummary(List<OrderItemModel> items) {
    if (items.isEmpty) return 'No items';
    return items
        .map((item) => '${item.productName} x${item.quantity}')
        .join(', ');
  }

  /// Open the full tracking screen for one order
  Future<void> _openTrackingScreen(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminOrderDetailsScreen(orderId: order.id!),
      ),
    );
    // Reload so any status change made inside is reflected here
    _loadOrders();
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
                    'No orders yet.\nOrders placed by customers will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
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
    final items = _itemsByOrder[order.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTrackingScreen(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                      ),
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
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
                '${order.orderType} • ${order.paymentMethod} • '
                '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // What the customer ordered
              Text(
                'Items: ${_itemsSummary(items)}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Quick status update + hint to tap for full details
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
                          await _orderService.updateOrderStatus(
                              order.id!, newStatus);
                          _loadOrders();
                          messenger.showSnackBar(
                            SnackBar(
                              content:
                                  Text('Order status updated to $newStatus.'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap card to track order',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
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
