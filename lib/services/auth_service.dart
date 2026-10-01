import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../utils/constants.dart';

/// Authentication service - handles login, registration, and session
class AuthService {
  final LocalStorageService _db = LocalStorageService.instance;

  /// Register a new customer account
  /// Returns the created user ID, or throws an exception on failure
  Future<int> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // Check if email already exists
    final existingUser = await _db.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email is already registered.');
    }

    final user = UserModel(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: AppConstants.roleCustomer,
      createdAt: DateTime.now(),
    );

    return await _db.registerUser(user);
  }

  /// Login with email and password
  /// Returns the user model if successful, null if credentials are invalid
  Future<UserModel?> login(String email, String password) async {
    return await _db.getUserByEmailAndPassword(email, password);
  }

  /// Login as admin (convenience method)
  Future<UserModel?> loginAdmin(String email, String password) async {
    final user = await _db.getUserByEmailAndPassword(email, password);
    if (user != null && user.role == AppConstants.roleAdmin) {
      return user;
    }
    return null;
  }

  /// Get user by ID
  Future<UserModel?> getUserById(int id) async {
    return await _db.getUserById(id);
  }

  /// Update user profile
  Future<void> updateProfile(UserModel user) async {
    await _db.updateUser(user);
  }

  /// Change user password
  Future<void> changePassword(int userId, String newPassword) async {
    final user = await _db.getUserById(userId);
    if (user != null) {
      final updatedUser = user.copyWith(password: newPassword);
      await _db.updateUser(updatedUser);
    }
  }
}
