import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/cart_item_model.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

/// Order service - handles order creation and management
class OrderService {
  final LocalStorageService _db = LocalStorageService.instance;

  /// Create a new order from cart items
  /// Returns the generated order number
  Future<String> createOrder({
    required int userId,
    required String customerName,
    required List<CartItemModel> cartItems,
    required String orderType,
    required String paymentMethod,
    String? address,
    String? landmark,
    String? deliveryInstructions,
  }) async {
    // Calculate totals
    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);
    final deliveryFee = orderType == AppConstants.orderTypeDelivery ? AppConstants.deliveryFee : 0.0;
    final total = subtotal + deliveryFee;

    // Generate order number: ORD-YYYYMMDD-XXX
    final orderNumber = _generateOrderNumber();

    // Create order
    final order = OrderModel(
      orderNumber: orderNumber,
      userId: userId,
      customerName: customerName,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      orderType: orderType,
      paymentMethod: paymentMethod,
      address: address,
      landmark: landmark,
      deliveryInstructions: deliveryInstructions,
      status: AppConstants.statusPending,
      createdAt: DateTime.now(),
    );

    // Create order items
    final orderItems = cartItems.map((item) => OrderItemModel(
      orderId: 0, // Will be set when the order is saved to local storage
      productId: item.product.id!,
      productName: item.product.name,
      quantity: item.quantity,
      price: item.product.price,
      subtotal: item.subtotal,
    )).toList();

    // Save order and its items to local storage
    await _db.createOrder(order, orderItems);

    return orderNumber;
  }

  /// Generate unique order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return 'ORD-$dateStr-$random';
  }

  /// Get all orders
  Future<List<OrderModel>> getAllOrders() async {
    return await _db.getAllOrders();
  }

  /// Get orders by user ID
  Future<List<OrderModel>> getOrdersByUser(int userId) async {
    return await _db.getOrdersByUser(userId);
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(int id) async {
    return await _db.getOrderById(id);
  }

  /// Get order items
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    return await _db.getOrderItems(orderId);
  }

  /// Update order status
  Future<void> updateOrderStatus(int orderId, String status) async {
    await _db.updateOrderStatus(orderId, status);
  }

  /// Get order count for a user
  Future<int> getOrderCountByUser(int userId) async {
    return await _db.getOrderCountByUser(userId);
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    return {
      'todayOrders': await _db.getTodayOrderCount(),
      'todaySales': await _db.getTodaySales(),
      'totalProducts': await _db.getProductCount(),
      'totalCustomers': await _db.getCustomerCount(),
      'totalOrders': await _db.getTotalOrderCount(),
      'completedOrders': await _db.getCompletedOrderCount(),
      'cancelledOrders': await _db.getCancelledOrderCount(),
      'totalSales': await _db.getTotalSales(),
    };
  }
}
