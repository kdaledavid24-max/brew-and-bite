import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Authentication provider - manages user login state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == AppConstants.roleAdmin;

  /// Initialize - check for saved session
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('user_email');
    if (savedEmail != null) {
      // Try to restore session
      final user = await _authService.login(savedEmail, prefs.getString('user_password') ?? '');
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        await prefs.setString('user_password', password);

        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new account
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateProfile(UserModel user) async {
    await _authService.updateProfile(user);
    _currentUser = user;
    notifyListeners();
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;

    // Verify current password
    if (_currentUser!.password != currentPassword) {
      _error = 'Current password is incorrect.';
      notifyListeners();
      return false;
    }

    await _authService.changePassword(_currentUser!.id!, newPassword);
    _currentUser = _currentUser!.copyWith(password: newPassword);
    notifyListeners();
    return true;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
