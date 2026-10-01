import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import 'admin_order_details_screen.dart';

/// Admin Orders Management Screen
///
/// Displays every customer order currently stored in local memory.
/// Reactively updates via [OrderProvider]. Status changes are reflected
/// immediately across the entire app.
class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _selectedFilter = 'All';

  final List<String> _filterOptions = const [
    'All',
    'Pending',
    'Confirmed',
    'Preparing',
    'Ready',
    'Completed',
    'Cancelled',
  ];

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

    // Filter orders
    List<Order> filteredOrders;
    if (_selectedFilter == 'All') {
      filteredOrders = orderProvider.orders;
    } else {
      filteredOrders = orderProvider.orders.where((o) {
        if (_selectedFilter == 'Ready') {
          return o.status == AppConstants.statusReady ||
              o.status == AppConstants.statusOutForDelivery;
        }
        if (_selectedFilter == 'Completed') {
          return o.status == AppConstants.statusCompleted ||
              o.status == AppConstants.statusDelivered;
        }
        return o.status.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            tooltip: 'Reset to Sample Orders',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              orderProvider.resetToSampleData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orders reset to demo sample data.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.electricBlue,
                      backgroundColor: isDark
                          ? AppColors.darkSurface
                          : AppColors.softIce,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.midnightNavy),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.electricBlue
                              : (isDark
                                  ? Colors.white12
                                  : AppColors.softBorder),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'All'
                                ? 'No orders in memory yet'
                                : 'No orders with status "$_selectedFilter"',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.midnightNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'When customers place orders, they appear here live.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildAdminOrderCard(
                        context,
                        order,
                        orderProvider,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOrderCard(
    BuildContext context,
    Order order,
    OrderProvider orderProvider,
    bool isDark,
  ) {
    final statusColor = AppColors.getStatusColor(order.status);
    final statusOptions = _getAvailableStatuses(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order number & status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.orderType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: order.orderType == AppConstants.orderTypeDelivery
                            ? AppColors.electricBlue
                            : AppColors.orangeAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date & customer
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
              style: TextStyle(
                fontSize: 11.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Customer Name & Phone
            Row(
              children: [
                Icon(Icons.person_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 6),
                Text(
                  order.customerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.phone_rounded,
                    size: 15,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 4),
                Text(
                  order.customerPhone,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Items breakdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : AppColors.softIce,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                order.itemsSummary,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Total & quick action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.paymentMethod} • Total:',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.electricBlue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminOrderDetailsScreen(orderId: order.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text('VIEW ORDER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Quick Status Change Dropdown
            Row(
              children: [
                Text(
                  'Change Status: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.softIce,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: statusOptions.contains(order.status)
                            ? order.status
                            : statusOptions.first,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        items: statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getStatusColor(status),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null &&
                              newStatus != order.status) {
                            orderProvider.updateOrderStatus(
                                order.id, newStatus);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Order ${order.orderNumber} updated to $newStatus'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
