import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';

/// Local In-Memory Order Provider
///
/// Stores all orders in app memory during runtime.
/// Shared between Customer and Admin interfaces.
/// No backend, database, or network required.
class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  int _orderCounter = 3; // Initialized to 3 for the sample orders
  String? _recentNotification;

  OrderProvider() {
    _seedSampleOrders();
  }

  /// All orders stored in memory (newest first)
  List<Order> get orders => List.unmodifiable(_orders);

  /// Most recent order notification message (e.g. for Admin snackbar)
  String? get recentNotification => _recentNotification;

  // ==================== DASHBOARD COUNTERS ====================

  /// Total count of all orders in memory
  int get totalOrders => _orders.length;

  /// Total pending orders
  int get pendingOrders =>
      _orders.where((o) => o.status == AppConstants.statusPending).length;

  /// Total confirmed orders
  int get confirmedOrders =>
      _orders.where((o) => o.status == AppConstants.statusConfirmed).length;

  /// Total orders currently being prepared
  int get preparingOrders =>
      _orders.where((o) => o.status == AppConstants.statusPreparing).length;

  /// Total orders that are ready or out for delivery
  int get readyOrders => _orders
      .where((o) =>
          o.status == AppConstants.statusReady ||
          o.status == AppConstants.statusOutForDelivery)
      .length;

  /// Total completed or delivered orders
  int get completedOrders => _orders
      .where((o) =>
          o.status == AppConstants.statusCompleted ||
          o.status == AppConstants.statusDelivered)
      .length;

  /// Total cancelled orders
  int get cancelledOrders =>
      _orders.where((o) => o.status == AppConstants.statusCancelled).length;

  /// Total sales amount - ONLY completed & delivered orders are counted
  double get totalSales {
    return _orders
        .where((o) =>
            o.status == AppConstants.statusCompleted ||
            o.status == AppConstants.statusDelivered)
        .fold(0.0, (sum, o) => sum + o.total);
  }

  /// Orders placed today
  int get todayOrdersCount {
    final now = DateTime.now();
    return _orders.where((o) =>
        o.createdAt.year == now.year &&
        o.createdAt.month == now.month &&
        o.createdAt.day == now.day).length;
  }

  /// Total sales for today (completed/delivered only)
  double get todaySales {
    final now = DateTime.now();
    return _orders
        .where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day &&
            (o.status == AppConstants.statusCompleted ||
                o.status == AppConstants.statusDelivered))
        .fold(0.0, (sum, o) => sum + o.total);
  }

  // ==================== ORDER OPERATIONS ====================

  /// Generate next sequential local order number (e.g., ORD-004, ORD-005)
  String generateNextOrderId() {
    _orderCounter++;
    return 'ORD-${_orderCounter.toString().padLeft(3, '0')}';
  }

  /// Add a new order placed by a customer
  void addOrder(Order order) {
    _orders.insert(0, order); // Insert at top so newest appears first
    _recentNotification = 'New Order Received! ${order.id} from ${order.customerName}';
    notifyListeners();
  }

  /// Update the status of an existing order
  void updateOrderStatus(String orderId, String newStatus) {
    final index = _orders.indexWhere(
        (o) => o.id.toLowerCase() == orderId.toLowerCase() ||
               o.orderNumber.toLowerCase() == orderId.toLowerCase());

    if (index != -1) {
      _orders[index].status = newStatus;
      _recentNotification =
          'Order ${_orders[index].id} updated to $newStatus';
      notifyListeners();
    }
  }

  /// Retrieve an order by its ID or orderNumber
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere(
        (o) =>
            o.id.toLowerCase() == id.toLowerCase() ||
            o.orderNumber.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get copy of all orders
  List<Order> getOrders() {
    return List.unmodifiable(_orders);
  }

  /// Get orders filtered by status
  List<Order> getOrdersByStatus(String status) {
    if (status.toLowerCase() == 'all') {
      return List.unmodifiable(_orders);
    }
    return _orders
        .where((o) => o.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  /// Get orders created by a specific customer
  List<Order> getOrdersForCustomer({int? userId, String? customerName}) {
    return _orders.where((o) {
      if (userId != null && o.userId != null) {
        return o.userId == userId;
      }
      if (customerName != null && customerName.isNotEmpty) {
        return o.customerName.toLowerCase().trim() ==
            customerName.toLowerCase().trim();
      }
      return true;
    }).toList();
  }

  /// Remove an order
  void removeOrder(String id) {
    _orders.removeWhere(
        (o) => o.id.toLowerCase() == id.toLowerCase() ||
               o.orderNumber.toLowerCase() == id.toLowerCase());
    notifyListeners();
  }

  /// Clear all temporary orders in memory
  void clearOrders() {
    _orders.clear();
    _orderCounter = 0;
    notifyListeners();
  }

  /// Reset in-memory orders to initial demo sample dataset
  void resetToSampleData() {
    _orders.clear();
    _orderCounter = 3;
    _seedSampleOrders();
    notifyListeners();
  }

  /// Dismiss notification
  void clearRecentNotification() {
    _recentNotification = null;
  }

  // ==================== INITIAL SAMPLE DATA ====================

  void _seedSampleOrders() {
    final now = DateTime.now();

    // Sample 1: Kristian Dale (Preparing - Delivery)
    _orders.add(
      Order(
        id: 'ORD-001',
        customerName: 'Kristian Dale',
        customerPhone: '09171234567',
        items: [
          CartItemModel(
            product: ProductModel(
              id: 1,
              categoryId: 1,
              name: 'Biscoff Latte',
              description:
                  'Creamy espresso combined with smooth milk and Biscoff flavor.',
              price: 150.0,
              imagePath: 'biscoff_latte',
              rating: 4.8,
              createdAt: now,
            ),
            quantity: 2,
          ),
          CartItemModel(
            product: ProductModel(
              id: 8,
              categoryId: 2,
              name: 'Chicken Salad',
              description:
                  'Fresh greens with grilled chicken and house dressing.',
              price: 170.0,
              imagePath: 'chicken_salad',
              rating: 4.7,
              createdAt: now,
            ),
            quantity: 1,
          ),
        ],
        subtotal: 470.0,
        deliveryFee: 30.0,
        total: 500.0,
        orderType: AppConstants.orderTypeDelivery,
        paymentMethod: AppConstants.paymentGCash,
        address: 'Unit 402, Sunshine Residences, Sampaloc, Manila',
        landmark: 'Near University Gate 3',
        deliveryInstructions: 'Ring doorbell or leave with concierge',
        status: AppConstants.statusPreparing,
        createdAt: now.subtract(const Duration(minutes: 25)),
        userId: 2,
      ),
    );

    // Sample 2: Maria Santos (Pending - Pickup)
    _orders.add(
      Order(
        id: 'ORD-002',
        customerName: 'Maria Santos',
        customerPhone: '09189876543',
        items: [
          CartItemModel(
            product: ProductModel(
              id: 9,
              categoryId: 3,
              name: 'Creamy Carbonara',
              description: 'Creamy pasta with savory sauce and toppings.',
              price: 180.0,
              imagePath: 'carbonara',
              rating: 4.8,
              createdAt: now,
            ),
            quantity: 1,
          ),
        ],
        subtotal: 180.0,
        deliveryFee: 0.0,
        total: 180.0,
        orderType: AppConstants.orderTypePickup,
        paymentMethod: AppConstants.paymentCash,
        address: 'Brew & Bite Store Counter (Pick-up)',
        status: AppConstants.statusPending,
        createdAt: now.subtract(const Duration(minutes: 10)),
        userId: 3,
      ),
    );

    // Sample 3: John Cruz (Completed - Pickup)
    _orders.add(
      Order(
        id: 'ORD-003',
        customerName: 'John Cruz',
        customerPhone: '09201122334',
        items: [
          CartItemModel(
            product: ProductModel(
              id: 2,
              categoryId: 1,
              name: 'Americano',
              description:
                  'Rich espresso mixed with hot water for a smooth and bold coffee.',
              price: 100.0,
              imagePath: 'americano',
              rating: 4.5,
              createdAt: now,
            ),
            quantity: 2,
          ),
        ],
        subtotal: 200.0,
        deliveryFee: 0.0,
        total: 200.0,
        orderType: AppConstants.orderTypePickup,
        paymentMethod: AppConstants.paymentCash,
        address: 'Brew & Bite Store Counter (Pick-up)',
        status: AppConstants.statusCompleted,
        createdAt: now.subtract(const Duration(hours: 2)),
        userId: 4,
      ),
    );
  }
}
