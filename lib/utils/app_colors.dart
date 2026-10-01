import 'package:flutter/material.dart';

/// App color palette for Brew & Bite
/// Aesthetic Dark Blue & Modern Foodpanda-style Theme
class AppColors {
  // Primary brand dark blue colors
  static const Color midnightNavy = Color(0xFF0F172A); // Deep slate midnight
  static const Color deepNavy = Color(0xFF1E293B);     // Surface navy
  static const Color navyCard = Color(0xFF1E3A8A);     // Rich royal dark blue
  static const Color primaryBlue = Color(0xFF1D4ED8);  // Vibrant primary blue
  static const Color electricBlue = Color(0xFF2563EB); // Foodpanda-style punchy blue
  static const Color skyBlue = Color(0xFF0284C7);      // Sky blue
  static const Color skyAccent = Color(0xFF38BDF8);    // Bright cyan/sky highlight
  static const Color softIce = Color(0xFFF0F7FF);      // Subtle blue-tinted card/bg
  static const Color softBorder = Color(0xFFE2E8F0);   // Crisp light border

  // Backward-compatible alias mappings
  static const Color darkBrown = Color(0xFF0F172A);    // Dark Blue
  static const Color coffeeBrown = Color(0xFF1E40AF);  // Deep Royal Blue
  static const Color cream = Color(0xFFF1F5F9);        // Slate Ice
  static const Color warmBeige = Color(0xFFCBD5E1);    // Slate Accent
  static const Color goldAccent = Color(0xFF38BDF8);   // Aesthetic Sky Blue
  static const Color orangeAccent = Color(0xFFF59E0B); // Amber Accent

  // Light mode colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF131D31);
  static const Color darkCard = Color(0xFF1A263D);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Semantic status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // Category colors
  static const Color coffeeColor = Color(0xFFD97706);
  static const Color saladColor = Color(0xFF10B981);
  static const Color pastaColor = Color(0xFFEA580C);

  /// Status badge color helper
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'confirmed':
        return const Color(0xFF3B82F6); // Blue
      case 'preparing':
        return const Color(0xFF8B5CF6); // Violet
      case 'ready':
      case 'out for delivery':
        return const Color(0xFF06B6D4); // Cyan
      case 'completed':
      case 'delivered':
        return const Color(0xFF10B981); // Emerald
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B);
    }
  }

  /// Status icon helper
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'confirmed':
        return Icons.thumb_up_alt_rounded;
      case 'preparing':
        return Icons.soup_kitchen_rounded;
      case 'ready':
        return Icons.takeout_dining_rounded;
      case 'out for delivery':
        return Icons.delivery_dining_rounded;
      case 'completed':
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
