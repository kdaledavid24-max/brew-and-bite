import 'package:flutter_test/flutter_test.dart';
import 'package:brew_and_bite/models/order_model.dart';
import 'package:brew_and_bite/models/cart_item_model.dart';
import 'package:brew_and_bite/models/product_model.dart';
import 'package:brew_and_bite/providers/order_provider.dart';
import 'package:brew_and_bite/utils/constants.dart';

void main() {
  group('OrderProvider Local In-Memory Tests', () {
    late OrderProvider orderProvider;

    setUp(() {
      orderProvider = OrderProvider();
    });

    test('Initializes with 3 sample orders', () {
      expect(orderProvider.orders.length, 3);
      expect(orderProvider.getOrderById('ORD-001'), isNotNull);
      expect(orderProvider.getOrderById('ORD-002'), isNotNull);
      expect(orderProvider.getOrderById('ORD-003'), isNotNull);
    });

    test('Dynamic counters calculation correctly calculates status counts', () {
      expect(orderProvider.totalOrders, 3);
      expect(orderProvider.pendingOrders, 1); // ORD-002
      expect(orderProvider.preparingOrders, 1); // ORD-001
      expect(orderProvider.completedOrders, 1); // ORD-003
      expect(orderProvider.cancelledOrders, 0);

      // Total sales ONLY counts completed & delivered orders (ORD-003: ₱200)
      expect(orderProvider.totalSales, 200.0);
    });

    test('Adding a customer order updates counters and stores in memory', () {
      final now = DateTime.now();
      final newOrderId = orderProvider.generateNextOrderId();
      expect(newOrderId, 'ORD-004');

      final order = Order(
        id: newOrderId,
        customerName: 'Kristian Dale',
        customerPhone: '09171234567',
        items: [
          CartItemModel(
            product: ProductModel(
              id: 1,
              categoryId: 1,
              name: 'Biscoff Latte',
              description: 'Latte',
              price: 150.0,
              imagePath: 'biscoff_latte',
              createdAt: now,
            ),
            quantity: 2,
          ),
          CartItemModel(
            product: ProductModel(
              id: 8,
              categoryId: 2,
              name: 'Chicken Salad',
              description: 'Salad',
              price: 170.0,
              imagePath: 'chicken_salad',
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
        address: 'Manila',
        status: AppConstants.statusPending,
        createdAt: now,
        userId: 2,
      );

      orderProvider.addOrder(order);

      expect(orderProvider.totalOrders, 4);
      expect(orderProvider.pendingOrders, 2);
      expect(orderProvider.orders.first.id, 'ORD-004'); // Newest first
    });

    test(
        'Step-by-step verification of Scenario 35 (Admin updates status, Customer sees changes)',
        () {
      // STEP 1-4: Customer places order
      final now = DateTime.now();
      final orderId = orderProvider.generateNextOrderId();
      final order = Order(
        id: orderId,
        customerName: 'Kristian Dale',
        customerPhone: '09171234567',
        items: [
          CartItemModel(
            product: ProductModel(
              id: 1,
              categoryId: 1,
              name: 'Biscoff Latte',
              description: 'Latte',
              price: 150.0,
              imagePath: 'biscoff_latte',
              createdAt: now,
            ),
            quantity: 2,
          ),
          CartItemModel(
            product: ProductModel(
              id: 8,
              categoryId: 2,
              name: 'Chicken Salad',
              description: 'Salad',
              price: 170.0,
              imagePath: 'chicken_salad',
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
        address: 'Sampaloc, Manila',
        status: AppConstants.statusPending,
        createdAt: now,
        userId: 2,
      );

      orderProvider.addOrder(order);
      expect(orderProvider.getOrderById(orderId)!.status, AppConstants.statusPending);

      // STEP 6-7: Admin changes Pending -> Confirmed
      orderProvider.updateOrderStatus(orderId, AppConstants.statusConfirmed);
      // STEP 9-10: Customer sees Confirmed
      expect(orderProvider.getOrderById(orderId)!.status, AppConstants.statusConfirmed);
      expect(orderProvider.confirmedOrders, 1);

      // STEP 11a: Confirmed -> Preparing
      orderProvider.updateOrderStatus(orderId, AppConstants.statusPreparing);
      expect(orderProvider.getOrderById(orderId)!.status, AppConstants.statusPreparing);
      expect(orderProvider.preparingOrders, 2); // Sample ORD-001 + new order

      // STEP 11b: Preparing -> Ready
      orderProvider.updateOrderStatus(orderId, AppConstants.statusReady);
      expect(orderProvider.getOrderById(orderId)!.status, AppConstants.statusReady);

      // STEP 11c: Ready -> Completed
      orderProvider.updateOrderStatus(orderId, AppConstants.statusCompleted);
      expect(orderProvider.getOrderById(orderId)!.status, AppConstants.statusCompleted);
      expect(orderProvider.completedOrders, 2); // Sample ORD-003 + new order

      // Total sales now includes ₱200 + ₱500 = ₱700
      expect(orderProvider.totalSales, 700.0);
    });

    test('removeOrder and clearOrders work as expected', () {
      orderProvider.removeOrder('ORD-001');
      expect(orderProvider.orders.length, 2);
      expect(orderProvider.getOrderById('ORD-001'), isNull);

      orderProvider.clearOrders();
      expect(orderProvider.orders.isEmpty, isTrue);
      expect(orderProvider.totalOrders, 0);
      expect(orderProvider.totalSales, 0.0);

      // Reset works
      orderProvider.resetToSampleData();
      expect(orderProvider.orders.length, 3);
    });
  });
}
