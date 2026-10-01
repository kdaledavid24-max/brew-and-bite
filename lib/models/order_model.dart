/// Order model representing a customer order
class OrderModel {
  final int? id;
  final String orderNumber;
  final int userId;
  final String customerName;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String orderType; // Pickup or Delivery
  final String paymentMethod;
  final String? address;
  final String? landmark;
  final String? deliveryInstructions;
  final String status;
  final DateTime createdAt;

  OrderModel({
    this.id,
    required this.orderNumber,
    required this.userId,
    required this.customerName,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderType,
    required this.paymentMethod,
    this.address,
    this.landmark,
    this.deliveryInstructions,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'customer_name': customerName,
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
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String,
      userId: map['user_id'] as int,
      customerName: map['customer_name'] as String,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      orderType: map['order_type'] as String,
      paymentMethod: map['payment_method'] as String,
      address: map['address'] as String?,
      landmark: map['landmark'] as String?,
      deliveryInstructions: map['delivery_instructions'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  OrderModel copyWith({
    int? id,
    String? orderNumber,
    int? userId,
    String? customerName,
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
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
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
    );
  }
}
