import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import 'order_details_screen.dart';

/// Orders screen with tabs for Active, Completed, and Cancelled orders.
///
/// The list auto-refreshes every few seconds, so when the admin updates
/// an order status the customer sees the change without doing anything.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();

    // Auto-refresh so admin status updates show up live
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _loadOrders(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  /// Load the customer's orders.
  /// [silent] = refresh in the background without showing the spinner.
  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent && mounted) setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _orders = await _orderService.getOrdersByUser(user.id!);
      }
    } catch (e) {
      // Keep the previous list if loading fails
    }
    if (mounted) setState(() => _isLoading = false);
  }

  List<OrderModel> _getFilteredOrders(String tab) {
    switch (tab) {
      case 'Active':
        return _orders.where((o) =>
            o.status != AppConstants.statusCompleted &&
            o.status != AppConstants.statusDelivered &&
            o.status != AppConstants.statusCancelled).toList();
      case 'Completed':
        return _orders.where((o) =>
            o.status == AppConstants.statusCompleted ||
            o.status == AppConstants.statusDelivered).toList();
      case 'Cancelled':
        return _orders.where((o) => o.status == AppConstants.statusCancelled).toList();
      default:
        return _orders;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
          labelColor: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          indicatorColor: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList('Active', isDark),
                _buildOrdersList('Completed', isDark),
                _buildOrdersList('Cancelled', isDark),
              ],
            ),
    );
  }

  Widget _buildOrdersList(String tab, bool isDark) {
    final filteredOrders = _getFilteredOrders(tab);

    if (filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tab == 'Active'
                        ? "You don't have any active orders."
                        : tab == 'Completed'
                            ? "You don't have any completed orders yet."
                            : "You don't have any cancelled orders.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (tab == 'Active') ...[
                    const SizedBox(height: 16),
                    Text(
                      'Start ordering to see your orders here.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return OrderCard(
            order: order,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: order.id!),
                ),
              );
              _loadOrders(); // Refresh after returning
            },
          );
        },
      ),
    );
  }
}
