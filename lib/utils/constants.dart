/// App-wide constants for Brew & Bite
/// Edit these values to customize the app
class AppConstants {
  // App info
  static const String appName = 'Brew & Bite';
  static const String tagline = 'Freshly Brewed. Freshly Made.';
  static const String appVersion = '1.0.0';

  // Currency
  static const String currencySymbol = '₱';

  // Delivery
  static const double deliveryFee = 30.0;
  static const double freeDeliveryThreshold = 500.0;

  // Default admin credentials (change these for production!)
  static const String adminEmail = 'admin@brewandbite.com';
  static const String adminPassword = 'admin123';

  // Order status values
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusPreparing = 'Preparing';
  static const String statusReady = 'Ready';
  static const String statusOutForDelivery = 'Out for Delivery';
  static const String statusCompleted = 'Completed';
  static const String statusDelivered = 'Delivered';
  static const String statusCancelled = 'Cancelled';

  // Order types
  static const String orderTypePickup = 'Pickup';
  static const String orderTypeDelivery = 'Delivery';

  // Payment methods
  static const String paymentCash = 'Cash';
  static const String paymentGCash = 'GCash';
  static const String paymentCard = 'Card';

  // User roles
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';
}
