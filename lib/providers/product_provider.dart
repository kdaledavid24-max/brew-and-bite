import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

/// Product provider - manages product catalog state
class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int? get selectedCategoryId => _selectedCategoryId;

  /// Get filtered products based on search and category
  List<ProductModel> get filteredProducts {
    var filtered = _products.where((p) => p.isAvailable).toList();

    // Apply category filter
    if (_selectedCategoryId != null) {
      filtered = filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  /// Load all products and categories
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
      _categories = await _productService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = 'Unable to load products. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search products
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    notifyListeners();
  }

  /// Add a new product
  Future<void> addProduct(ProductModel product) async {
    await _productService.addProduct(product);
    await loadProducts();
  }

  /// Update a product
  Future<void> updateProduct(ProductModel product) async {
    await _productService.updateProduct(product);
    await loadProducts();
  }

  /// Delete a product
  Future<void> deleteProduct(int id) async {
    await _productService.deleteProduct(id);
    await loadProducts();
  }

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    return await _productService.getProductsByCategory(categoryId);
  }
}
