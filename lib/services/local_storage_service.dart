import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../utils/constants.dart';

/// Local storage service - handles all data persistence using
/// Flutter's SharedPreferences (key-value local storage).
///
/// Every collection (users, categories, products, orders, order_items)
/// is stored as a JSON string under its own key. On first launch the
/// storage is seeded with a default admin account, 3 categories and
/// 11 sample products.
///
/// This is the single source of truth for all app data - no database
/// and no backend server is required.
class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._init();

  LocalStorageService._init();

  // ==================== STORAGE KEYS ====================
  static const String _keyUsers = 'bb_users';
  static const String _keyCategories = 'bb_categories';
  static const String _keyProducts = 'bb_products';
  static const String _keyOrders = 'bb_orders';
  static const String _keyOrderItems = 'bb_order_items';
  static const String _keySeeded = 'bb_seeded'; // first-launch flag

  /// Cached init future so seeding only ever runs once per app session
  Future<void>? _initFuture;

  /// Make sure sample data exists before any read/write operation
  Future<void> _ensureReady() {
    return _initFuture ??= _seedIfNeeded();
  }

  // ==================== LOW-LEVEL HELPERS ====================

  /// Read a JSON list stored under [key] and return it as a list of maps
  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  /// Serialize a list of maps to JSON and save it under [key]
  Future<void> _writeList(String key, List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(rows));
  }

  /// Generate the next auto-increment style ID for a collection
  int _nextId(List<Map<String, dynamic>> rows) {
    var max = 0;
    for (final row in rows) {
      final id = (row['id'] as num?)?.toInt() ?? 0;
      if (id > max) max = id;
    }
    return max + 1;
  }

  // ==================== SEED / FIRST-LAUNCH DATA ====================

  /// Insert default admin, categories, and sample products on first launch
  Future<void> _seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keySeeded) ?? false) return;

    // Default admin account
    final users = <Map<String, dynamic>>[
      UserModel(
        id: 1,
        name: 'Admin',
        email: AppConstants.adminEmail,
        phone: '09171234567',
        password: AppConstants.adminPassword,
        role: AppConstants.roleAdmin,
        createdAt: DateTime.now(),
      ).toMap(),
    ];

    // Default categories: Coffee, Salad, Pasta
    final categories = <Map<String, dynamic>>[
      CategoryModel(id: 1, name: 'Coffee', description: 'Freshly brewed coffee drinks', icon: 'coffee').toMap(),
      CategoryModel(id: 2, name: 'Salad', description: 'Fresh and healthy salads', icon: 'salad').toMap(),
      CategoryModel(id: 3, name: 'Pasta', description: 'Delicious pasta dishes', icon: 'pasta').toMap(),
    ];

    // Sample products (5 coffee, 3 salad, 3 pasta)
    final now = DateTime.now();
    final sampleProducts = <ProductModel>[
      ProductModel(id: 1, categoryId: 1, name: 'Biscoff Latte', description: 'Creamy espresso combined with smooth milk and Biscoff flavor.', price: 150.0, imagePath: 'biscoff_latte', rating: 4.8, createdAt: now),
      ProductModel(id: 2, categoryId: 1, name: 'Americano', description: 'Rich espresso mixed with hot water for a smooth and bold coffee.', price: 100.0, imagePath: 'americano', rating: 4.5, createdAt: now),
      ProductModel(id: 3, categoryId: 1, name: 'Mocha Latte', description: 'Espresso blended with chocolate and steamed milk.', price: 140.0, imagePath: 'mocha_latte', rating: 4.7, createdAt: now),
      ProductModel(id: 4, categoryId: 1, name: 'Caramel Macchiato', description: 'Espresso, steamed milk, and caramel flavor topped with foam.', price: 155.0, imagePath: 'caramel_macchiato', rating: 4.6, createdAt: now),
      ProductModel(id: 5, categoryId: 1, name: 'Dirty Matcha', description: 'Creamy matcha layered with espresso for a unique combination.', price: 160.0, imagePath: 'dirty_matcha', rating: 4.4, createdAt: now),
      ProductModel(id: 6, categoryId: 2, name: 'Caesar Salad', description: 'Fresh lettuce, crispy toppings, cheese, and Caesar dressing.', price: 140.0, imagePath: 'caesar_salad', rating: 4.5, createdAt: now),
      ProductModel(id: 7, categoryId: 2, name: 'Garden Fresh Salad', description: 'Fresh vegetables served with a light dressing.', price: 130.0, imagePath: 'garden_salad', rating: 4.3, createdAt: now),
      ProductModel(id: 8, categoryId: 2, name: 'Chicken Salad', description: 'Fresh greens with grilled chicken and house dressing.', price: 170.0, imagePath: 'chicken_salad', rating: 4.7, createdAt: now),
      ProductModel(id: 9, categoryId: 3, name: 'Creamy Carbonara', description: 'Creamy pasta with savory sauce and toppings.', price: 180.0, imagePath: 'carbonara', rating: 4.8, createdAt: now),
      ProductModel(id: 10, categoryId: 3, name: 'Chicken Alfredo', description: 'Creamy Alfredo pasta served with tender chicken.', price: 190.0, imagePath: 'chicken_alfredo', rating: 4.6, createdAt: now),
      ProductModel(id: 11, categoryId: 3, name: 'Spaghetti Bolognese', description: 'Classic spaghetti with rich tomato-based meat sauce.', price: 175.0, imagePath: 'spaghetti_bolognese', rating: 4.5, createdAt: now),
    ];

    await _writeList(_keyUsers, users);
    await _writeList(_keyCategories, categories);
    await _writeList(_keyProducts, sampleProducts.map((p) => p.toMap()).toList());
    await _writeList(_keyOrders, []);
    await _writeList(_keyOrderItems, []);
    await prefs.setBool(_keySeeded, true);
  }

  // ==================== USER OPERATIONS ====================

  /// Register a new user - returns the generated user ID
  Future<int> registerUser(UserModel user) async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    final id = _nextId(users);
    final row = {...user.toMap(), 'id': id};
    users.add(row);
    await _writeList(_keyUsers, users);
    return id;
  }

  /// Get user by email and password (for login)
  Future<UserModel?> getUserByEmailAndPassword(String email, String password) async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    for (final row in users) {
      if (row['email'] == email && row['password'] == password) {
        return UserModel.fromMap(row);
      }
    }
    return null;
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    for (final row in users) {
      if (row['email'] == email) return UserModel.fromMap(row);
    }
    return null;
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int id) async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    for (final row in users) {
      if (row['id'] == id) return UserModel.fromMap(row);
    }
    return null;
  }

  /// Update user - replaces the row that has the same ID
  Future<int> updateUser(UserModel user) async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    final index = users.indexWhere((row) => row['id'] == user.id);
    if (index == -1) return 0;
    users[index] = user.toMap();
    await _writeList(_keyUsers, users);
    return 1;
  }

  /// Get all customers (non-admin users), newest first
  Future<List<UserModel>> getAllCustomers() async {
    await _ensureReady();
    final users = await _readList(_keyUsers);
    final customers = users
        .where((row) => row['role'] == AppConstants.roleCustomer)
        .map(UserModel.fromMap)
        .toList();
    customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return customers;
  }

  // ==================== CATEGORY OPERATIONS ====================

  /// Get all categories ordered by ID
  Future<List<CategoryModel>> getAllCategories() async {
    await _ensureReady();
    final rows = await _readList(_keyCategories);
    rows.sort((a, b) => ((a['id'] as num?) ?? 0).compareTo(((b['id'] as num?) ?? 0)));
    return rows.map(CategoryModel.fromMap).toList();
  }

  /// Add a new category
  Future<int> addCategory(CategoryModel category) async {
    await _ensureReady();
    final rows = await _readList(_keyCategories);
    final id = _nextId(rows);
    rows.add({...category.toMap(), 'id': id});
    await _writeList(_keyCategories, rows);
    return id;
  }

  /// Update a category
  Future<int> updateCategory(CategoryModel category) async {
    await _ensureReady();
    final rows = await _readList(_keyCategories);
    final index = rows.indexWhere((row) => row['id'] == category.id);
    if (index == -1) return 0;
    rows[index] = category.toMap();
    await _writeList(_keyCategories, rows);
    return 1;
  }

  /// Delete a category
  Future<int> deleteCategory(int id) async {
    await _ensureReady();
    final rows = await _readList(_keyCategories);
    final kept = rows.where((row) => row['id'] != id).toList();
    await _writeList(_keyCategories, kept);
    return rows.length - kept.length;
  }

  // ==================== PRODUCT OPERATIONS ====================

  /// Get all products ordered by name
  Future<List<ProductModel>> getAllProducts() async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final products = rows.map(ProductModel.fromMap).toList();
    products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  /// Get products by category, ordered by name
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final products = rows
        .where((row) => row['category_id'] == categoryId)
        .map(ProductModel.fromMap)
        .toList();
    products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    for (final row in rows) {
      if (row['id'] == id) return ProductModel.fromMap(row);
    }
    return null;
  }

  /// Add a new product - returns the generated product ID
  Future<int> addProduct(ProductModel product) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final id = _nextId(rows);
    rows.add({...product.toMap(), 'id': id});
    await _writeList(_keyProducts, rows);
    return id;
  }

  /// Update a product
  Future<int> updateProduct(ProductModel product) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final index = rows.indexWhere((row) => row['id'] == product.id);
    if (index == -1) return 0;
    rows[index] = product.toMap();
    await _writeList(_keyProducts, rows);
    return 1;
  }

  /// Delete a product
  Future<int> deleteProduct(int id) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final kept = rows.where((row) => row['id'] != id).toList();
    await _writeList(_keyProducts, kept);
    return rows.length - kept.length;
  }

  /// Search products by name (case-insensitive)
  Future<List<ProductModel>> searchProducts(String query) async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    final lowerQuery = query.toLowerCase();
    final products = rows
        .where((row) => (row['name'] as String).toLowerCase().contains(lowerQuery))
        .map(ProductModel.fromMap)
        .toList();
    products.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return products;
  }

  // ==================== ORDER OPERATIONS ====================

  /// Create a new order together with its items
  /// Returns the generated order ID
  Future<int> createOrder(OrderModel order, List<OrderItemModel> items) async {
    await _ensureReady();

    final orders = await _readList(_keyOrders);
    final orderItems = await _readList(_keyOrderItems);

    // Assign order ID, then attach it to every item
    final orderId = _nextId(orders);
    orders.add({...order.toMap(), 'id': orderId});

    for (final item in items) {
      orderItems.add({
        ...item.toMap(),
        'id': _nextId(orderItems),
        'order_id': orderId,
      });
    }

    await _writeList(_keyOrders, orders);
    await _writeList(_keyOrderItems, orderItems);
    return orderId;
  }

  /// Get all orders, newest first
  Future<List<OrderModel>> getAllOrders() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    final orders = rows.map(OrderModel.fromMap).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// Get orders placed by one user, newest first
  Future<List<OrderModel>> getOrdersByUser(int userId) async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    final orders = rows
        .where((row) => row['user_id'] == userId)
        .map(OrderModel.fromMap)
        .toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(int id) async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    for (final row in rows) {
      if (row['id'] == id) return OrderModel.fromMap(row);
    }
    return null;
  }

  /// Get items belonging to an order
  Future<List<OrderItemModel>> getOrderItems(int orderId) async {
    await _ensureReady();
    final rows = await _readList(_keyOrderItems);
    return rows
        .where((row) => row['order_id'] == orderId)
        .map(OrderItemModel.fromMap)
        .toList();
  }

  /// Update order status
  Future<int> updateOrderStatus(int orderId, String status) async {
    await _ensureReady();
    final orders = await _readList(_keyOrders);
    final index = orders.indexWhere((row) => row['id'] == orderId);
    if (index == -1) return 0;
    orders[index]['status'] = status;
    await _writeList(_keyOrders, orders);
    return 1;
  }

  // ==================== STATISTICS ====================

  /// Get order count for a user
  Future<int> getOrderCountByUser(int userId) async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    return rows.where((row) => row['user_id'] == userId).length;
  }

  /// String of today's date (yyyy-MM-dd) used to match created_at values
  String _todayPrefix() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  /// Get today's order count
  Future<int> getTodayOrderCount() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    final prefix = _todayPrefix();
    return rows.where((row) => (row['created_at'] as String).startsWith(prefix)).length;
  }

  /// Get today's sales total (cancelled orders excluded)
  Future<double> getTodaySales() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    final prefix = _todayPrefix();
    var total = 0.0;
    for (final row in rows) {
      if ((row['created_at'] as String).startsWith(prefix) &&
          row['status'] != AppConstants.statusCancelled) {
        total += (row['total'] as num).toDouble();
      }
    }
    return total;
  }

  /// Get total sales (cancelled orders excluded)
  Future<double> getTotalSales() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    var total = 0.0;
    for (final row in rows) {
      if (row['status'] != AppConstants.statusCancelled) {
        total += (row['total'] as num).toDouble();
      }
    }
    return total;
  }

  /// Get completed order count
  Future<int> getCompletedOrderCount() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    return rows
        .where((row) =>
            row['status'] == AppConstants.statusCompleted ||
            row['status'] == AppConstants.statusDelivered)
        .length;
  }

  /// Get cancelled order count
  Future<int> getCancelledOrderCount() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    return rows.where((row) => row['status'] == AppConstants.statusCancelled).length;
  }

  /// Get total order count
  Future<int> getTotalOrderCount() async {
    await _ensureReady();
    final rows = await _readList(_keyOrders);
    return rows.length;
  }

  /// Get product count
  Future<int> getProductCount() async {
    await _ensureReady();
    final rows = await _readList(_keyProducts);
    return rows.length;
  }

  /// Get customer count
  Future<int> getCustomerCount() async {
    await _ensureReady();
    final rows = await _readList(_keyUsers);
    return rows.where((row) => row['role'] == AppConstants.roleCustomer).length;
  }

  // ==================== RESET (useful for demos) ====================

  /// Erase every stored collection and re-seed the sample data.
  /// Useful for a classroom demo when you want a clean state.
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsers);
    await prefs.remove(_keyCategories);
    await prefs.remove(_keyProducts);
    await prefs.remove(_keyOrders);
    await prefs.remove(_keyOrderItems);
    await prefs.remove(_keySeeded);
    _initFuture = null;
    await _ensureReady();
  }
}
