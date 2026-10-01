import '../services/local_storage_service.dart';

/// Optional persistence helper for orders
class OrderService {
  final LocalStorageService _db = LocalStorageService.instance;

  /// Generate unique order number (e.g. ORD-004)
  String generateOrderNumber(int count) {
    return 'ORD-${(count + 1).toString().padLeft(3, '0')}';
  }

  /// Get dashboard statistics from local storage (if needed)
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
