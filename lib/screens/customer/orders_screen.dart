import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/order_card.dart';
import 'order_details_screen.dart';

/// Customer My Orders Screen
///
/// Reactively reads orders directly from shared [OrderProvider].
/// Whenever an Admin updates any order status, this screen rebuilds
/// immediately via ChangeNotifier.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = const ['All', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Order> _filterOrders(List<Order> allOrders, String tab, int? userId, String? userName) {
    // Show orders placed by this customer (or all if demo testing)
    final customerOrders = allOrders.where((o) {
      if (userId != null && o.userId != null) {
        return o.userId == userId;
      }
      if (userName != null && userName.isNotEmpty) {
        return o.customerName.toLowerCase().contains(userName.toLowerCase());
      }
      return true;
    }).toList();

    // Fallback: If customer has placed 0 orders, show all active demo orders so user has items to track
    final ordersToDisplay = customerOrders.isNotEmpty ? customerOrders : allOrders;

    switch (tab) {
      case 'Active':
        return ordersToDisplay
            .where((o) =>
                o.status != AppConstants.statusCompleted &&
                o.status != AppConstants.statusDelivered &&
                o.status != AppConstants.statusCancelled)
            .toList();
      case 'Completed':
        return ordersToDisplay
            .where((o) =>
                o.status == AppConstants.statusCompleted ||
                o.status == AppConstants.statusDelivered)
            .toList();
      case 'Cancelled':
        return ordersToDisplay
            .where((o) => o.status == AppConstants.statusCancelled)
            .toList();
      case 'All':
      default:
        return ordersToDisplay;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppColors.electricBlue,
          indicatorWeight: 3,
          labelColor: isDark ? AppColors.skyAccent : AppColors.electricBlue,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filtered = _filterOrders(
                orderProvider.orders,
                tab,
                currentUser?.id,
                currentUser?.name,
              );
              return _buildOrdersList(tab, filtered, isDark);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(String tab, List<Order> orders, bool isDark) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.softIce,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                tab == 'Active'
                    ? "No active orders right now"
                    : tab == 'Completed'
                        ? "No completed orders yet"
                        : tab == 'Cancelled'
                            ? "No cancelled orders"
                            : "No orders found",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Orders placed will appear here with live tracking.",
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
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                  orderId: order.id,
                  orderNumber: order.id,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
