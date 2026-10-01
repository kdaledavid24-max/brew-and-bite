import 'cart_item_model.dart';

/// Order model representing a customer order in local memory
class Order {
  final String id; // e.g., 'ORD-001'
  final String customerName;
  final String customerPhone;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String orderType; // 'Pickup' or 'Delivery'
  final String paymentMethod; // 'Cash', 'GCash', 'Card'
  final String address;
  final String? landmark;
  final String? deliveryInstructions;
  String status; // 'Pending', 'Confirmed', 'Preparing', 'Ready', 'Completed', 'Cancelled', etc.
  final DateTime createdAt;
  final int? userId;

  Order({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderType,
    required this.paymentMethod,
    required this.address,
    this.landmark,
    this.deliveryInstructions,
    required this.status,
    required this.createdAt,
    this.userId,
  });

  /// Compatibility getter: orderNumber equals id (e.g., 'ORD-001')
  String get orderNumber => id;

  /// Human-readable summary of ordered items (e.g., "Biscoff Latte x2, Salad x1")
  String get itemsSummary {
    if (items.isEmpty) return 'No items';
    return items.map((i) => '${i.product.name} x${i.quantity}').join(', ');
  }

  /// Total count of individual food items in this order
  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  Order copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? orderType,
    String? paymentMethod,
    String? address,
    String? landmark,
    String? deliveryInstructions,
    String? status,
    DateTime? createdAt,
    int? userId,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      orderType: orderType ?? this.orderType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'order_type': orderType,
      'payment_method': paymentMethod,
      'address': address,
      'landmark': landmark,
      'delivery_instructions': deliveryInstructions,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: (map['id'] ?? map['order_number'] ?? 'ORD-000').toString(),
      customerName: map['customer_name'] as String? ?? 'Guest Customer',
      customerPhone: map['customer_phone'] as String? ?? '09XXXXXXXXX',
      items: (map['items'] as List<dynamic>?)
              ?.map((itemMap) =>
                  CartItemModel.fromMap(Map<String, dynamic>.from(itemMap as Map)))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      orderType: map['order_type'] as String? ?? 'Pickup',
      paymentMethod: map['payment_method'] as String? ?? 'Cash',
      address: map['address'] as String? ?? '',
      landmark: map['landmark'] as String?,
      deliveryInstructions: map['delivery_instructions'] as String?,
      status: map['status'] as String? ?? 'Pending',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      userId: map['user_id'] as int?,
    );
  }
}

/// Backward compatibility typedef
typedef OrderModel = Order;
