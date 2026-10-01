import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'order_success_screen.dart';

/// Checkout screen for reviewing and placing orders
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

  String _orderType = AppConstants.orderTypePickup;
  String _paymentMethod = AppConstants.paymentCash;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill customer info
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      if (user.address != null) {
        _addressController.text = user.address!;
      }
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
      final orderService = OrderService();
      final user = context.read<AuthProvider>().currentUser!;

      final orderNumber = await orderService.createOrder(
        userId: user.id!,
        customerName: _nameController.text.trim(),
        cartItems: cart.items,
        orderType: _orderType,
        paymentMethod: _paymentMethod,
        address: _orderType == AppConstants.orderTypeDelivery ? _addressController.text.trim() : null,
        landmark: _orderType == AppConstants.orderTypeDelivery ? _landmarkController.text.trim() : null,
        deliveryInstructions: _orderType == AppConstants.orderTypeDelivery ? _deliveryInstructionsController.text.trim() : null,
      );

      // Clear cart after successful order
      cart.clearCart();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(orderNumber: orderNumber),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Information
              _buildSectionTitle('Customer Information', isDark),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Order Type
              _buildSectionTitle('Order Type', isDark),
              const SizedBox(height: 12),
              _buildOrderTypeSelector(isDark),
              const SizedBox(height: 24),

              // Delivery Address (only for delivery)
              if (_orderType == AppConstants.orderTypeDelivery) ...[
                _buildSectionTitle('Delivery Address', isDark),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Address',
                  hint: 'Enter your complete address',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_outlined,
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
                  hint: 'Near...',
                  controller: _landmarkController,
                  prefixIcon: Icons.flag_outlined,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Delivery Instructions (Optional)',
                  hint: 'e.g., Gate code, floor number...',
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
                  label: 'GCash Number',
                  hint: 'Enter your GCash number',
                  controller: _gcashNumberController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                  validator: (value) {
                    if (_paymentMethod == AppConstants.paymentGCash) {
                      if (value == null || value.trim().isEmpty) {
                        return 'GCash number is required.';
                      }
                    }
                    return null;
                  },
                ),
              ],
              if (_paymentMethod == AppConstants.paymentCard) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo Payment - No real card information is stored.',
                          style: TextStyle(fontSize: 12, color: AppColors.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Order Summary
              _buildSectionTitle('Order Summary', isDark),
              const SizedBox(height: 12),
              _buildOrderSummary(context, isDark, cart),
              const SizedBox(height: 32),

              // Place Order button
              CustomButton(
                text: 'PLACE ORDER',
                onPressed: _placeOrder,
                isLoading: _isPlacingOrder,
                icon: Icons.check_circle_outline,
              ),
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
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildOrderTypeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            title: 'Pickup',
            icon: Icons.storefront,
            isSelected: _orderType == AppConstants.orderTypePickup,
            onTap: () => setState(() => _orderType = AppConstants.orderTypePickup),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            title: 'Delivery',
            icon: Icons.delivery_dining,
            isSelected: _orderType == AppConstants.orderTypeDelivery,
            onTap: () => setState(() => _orderType = AppConstants.orderTypeDelivery),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(bool isDark) {
    return Column(
      children: [
        _buildPaymentOption(
          title: 'Cash',
          icon: Icons.payments_outlined,
          value: AppConstants.paymentCash,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          title: 'GCash',
          icon: Icons.phone_android,
          value: AppConstants.paymentGCash,
          isDark: isDark,
        ),
        const SizedBox(height: 8),
        _buildPaymentOption(
          title: 'Card (Demo)',
          icon: Icons.credit_card,
          value: AppConstants.paymentCard,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.goldAccent.withValues(alpha: 0.2) : AppColors.coffeeBrown.withValues(alpha: 0.1))
              : (isDark ? AppColors.darkSurface : AppColors.cream),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                    : (isDark ? AppColors.darkText : AppColors.lightText),
              ),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.goldAccent.withValues(alpha: 0.2) : AppColors.coffeeBrown.withValues(alpha: 0.1))
              : (isDark ? AppColors.darkSurface : AppColors.cream),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.goldAccent : AppColors.coffeeBrown)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isDark, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Items
          ...cart.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} x${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ),
                  Text(
                    '${AppConstants.currencySymbol}${item.subtotal.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${cart.subtotal.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Delivery fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                _orderType == AppConstants.orderTypeDelivery
                    ? '${AppConstants.currencySymbol}${AppConstants.deliveryFee.toStringAsFixed(0)}'
                    : 'Free',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const Divider(),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Text(
                '${AppConstants.currencySymbol}${(cart.subtotal + (_orderType == AppConstants.orderTypeDelivery ? AppConstants.deliveryFee : 0)).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
