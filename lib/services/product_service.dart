import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/local_storage_service.dart';

/// Product service - handles all product and category operations
class ProductService {
  final LocalStorageService _db = LocalStorageService.instance;

  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    return await _db.getAllProducts();
  }

  /// Get products by category ID
  Future<List<ProductModel>> getProductsByCategory(int categoryId) async {
    return await _db.getProductsByCategory(categoryId);
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(int id) async {
    return await _db.getProductById(id);
  }

  /// Add a new product
  Future<int> addProduct(ProductModel product) async {
    return await _db.addProduct(product);
  }

  /// Update an existing product
  Future<void> updateProduct(ProductModel product) async {
    await _db.updateProduct(product);
  }

  /// Delete a product
  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
  }

  /// Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    return await _db.searchProducts(query);
  }

  /// Get all categories
  Future<List<CategoryModel>> getAllCategories() async {
    return await _db.getAllCategories();
  }

  /// Add a new category
  Future<int> addCategory(CategoryModel category) async {
    return await _db.addCategory(category);
  }

  /// Update a category
  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateCategory(category);
  }

  /// Delete a category
  Future<void> deleteCategory(int id) async {
    await _db.deleteCategory(id);
  }
}
