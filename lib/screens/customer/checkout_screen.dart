import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'order_success_screen.dart';

/// Checkout screen for reviewing and placing local orders
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();
  final _gcashNumberController = TextEditingController();

  String _orderType = AppConstants.orderTypeDelivery;
  String _paymentMethod = AppConstants.paymentCash;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill customer info if logged in
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      if (user.address != null && user.address!.isNotEmpty) {
        _addressController.text = user.address!;
      }
    } else {
      // Default to Kristian Dale if guest/testing
      _nameController.text = 'Kristian Dale';
      _phoneController.text = '09171234567';
      _addressController.text = 'Unit 402, Sunshine Residences, Sampaloc, Manila';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _deliveryInstructionsController.dispose();
    _gcashNumberController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final orderProvider = context.read<OrderProvider>();
      final user = context.read<AuthProvider>().currentUser;
      final subtotal = cart.subtotal;
      final deliveryFee = _orderType == AppConstants.orderTypeDelivery
          ? AppConstants.deliveryFee
          : 0.0;
      final total = subtotal + deliveryFee;
      final orderId = orderProvider.generateNextOrderId();

      final newOrder = Order(
        id: orderId,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        items: List<CartItemModel>.from(cart.items),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        total: total,
        orderType: _orderType,
        paymentMethod: _paymentMethod,
        address: _orderType == AppConstants.orderTypeDelivery
            ? _addressController.text.trim()
            : 'Brew & Bite Store Counter (Pick-up)',
        landmark: _orderType == AppConstants.orderTypeDelivery &&
                _landmarkController.text.trim().isNotEmpty
            ? _landmarkController.text.trim()
            : null,
        deliveryInstructions: _orderType == AppConstants.orderTypeDelivery &&
                _deliveryInstructionsController.text.trim().isNotEmpty
            ? _deliveryInstructionsController.text.trim()
            : null,
        status: AppConstants.statusPending,
        createdAt: DateTime.now(),
        userId: user?.id,
      );

      // Add to shared local memory provider
      orderProvider.addOrder(newOrder);

      // Clear shopping cart
      cart.clearCart();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderNumber: newOrder.id,
            order: newOrder,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Type Toggle (Foodpanda aesthetic pill)
              _buildSectionTitle('Fulfillment Method', isDark),
              const SizedBox(height: 12),
              _buildOrderTypeSelector(isDark),
              const SizedBox(height: 24),

              // Customer Information
              _buildSectionTitle('Contact Details', isDark),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Customer Name',
                hint: 'Enter your name (e.g. Kristian Dale)',
                controller: _nameController,
                prefixIcon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Customer name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                hint: '09XXXXXXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Delivery Address (shown for delivery orders)
              if (_orderType == AppConstants.orderTypeDelivery) ...[
                _buildSectionTitle('Delivery Address', isDark),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Complete Address',
                  hint: 'Street, House/Unit No., Barangay, City',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_rounded,
                  validator: (value) {
                    if (_orderType == AppConstants.orderTypeDelivery) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Address is required for delivery.';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Landmark (Optional)',
                  hint: 'e.g. Near University Gate 3',
                  controller: _landmarkController,
                  prefixIcon: Icons.flag_rounded,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Delivery Instructions (Optional)',
                  hint: 'e.g., Leave with lobby concierge, ring doorbell',
                  controller: _deliveryInstructionsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
              ],

              // Payment Method
              _buildSectionTitle('Payment Method', isDark),
              const SizedBox(height: 12),
              _buildPaymentMethodSelector(isDark),
              if (_paymentMethod == AppConstants.paymentGCash) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'GCash Mobile Number',
                  hint: '09XXXXXXXXX',
                  controller: _gcashNumberController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android_rounded,
                  validator: (value) {
                    if (_paymentMethod == AppConstants.paymentGCash) {
                      if (value == null || value.trim().isEmpty) {
                        return 'GCash number is required for GCash payment.';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Order Summary
              _buildSectionTitle('Order Summary', isDark),
              const SizedBox(height: 12),
              _buildOrderSummary(context, isDark, cart),
              const SizedBox(height: 32),

              // PLACE ORDER Button
              CustomButton(
                text: 'PLACE ORDER',
                onPressed: _placeOrder,
                isLoading: _isPlacingOrder,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
        color: isDark ? AppColors.darkText : AppColors.midnightNavy,
      ),
    );
  }

  Widget _buildOrderTypeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.softIce,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypePill(
              title: 'Delivery',
              subtitle: '₱30 fee • 20-30 min',
              icon: Icons.delivery_dining_rounded,
              isSelected: _orderType == AppConstants.orderTypeDelivery,
              onTap: () => setState(() => _orderType = AppConstants.orderTypeDelivery),
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildTypePill(
              title: 'Pickup',
              subtitle: 'Free • Ready in 15 min',
              icon: Icons.storefront_rounded,
              isSelected: _orderType == AppConstants.orderTypePickup,
              onTap: () => setState(() => _orderType = AppConstants.orderTypePickup),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypePill({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.navyCard : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.electricBlue
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.midnightNavy)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.electricBlue
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(bool isDark) {
    return Column(
      children: [
        _buildPaymentOption(
          title: 'Cash on Delivery / Counter',
          icon: Icons.payments_rounded,
          value: AppConstants.paymentCash,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildPaymentOption(
          title: 'GCash (E-Wallet)',
          icon: Icons.phone_android_rounded,
          value: AppConstants.paymentGCash,
          isDark: isDark,
        ),
        const SizedBox(height: 10),
        _buildPaymentOption(
          title: 'Credit / Debit Card (Demo Simulation)',
          icon: Icons.credit_card_rounded,
          value: AppConstants.paymentCard,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.electricBlue.withValues(alpha: 0.15)
                  : AppColors.softIce)
              : (isDark ? AppColors.darkSurface : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.electricBlue
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.softBorder),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.electricBlue.withValues(alpha: 0.15)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.softIce),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.electricBlue
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? AppColors.electricBlue
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(
      BuildContext context, bool isDark, CartProvider cart) {
    final subtotal = cart.subtotal;
    final deliveryFee =
        _orderType == AppConstants.orderTypeDelivery ? AppConstants.deliveryFee : 0.0;
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...cart.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} × ${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.midnightNavy,
                      ),
                    ),
                  ),
                  Text(
                    '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkText
                          : AppColors.midnightNavy,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                _orderType == AppConstants.orderTypeDelivery
                    ? '${AppConstants.currencySymbol}${deliveryFee.toStringAsFixed(0)}'
                    : 'Free (Store Pickup)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _orderType == AppConstants.orderTypeDelivery
                      ? (isDark ? AppColors.darkText : AppColors.midnightNavy)
                      : AppColors.success,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.electricBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
