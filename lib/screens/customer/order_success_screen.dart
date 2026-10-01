import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'main_screen.dart';
import 'order_details_screen.dart';

/// Order success screen shown immediately after placing a local order
class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;
  final Order? order;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStatus = order?.status ?? AppConstants.statusPending;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Success checkmark bubble with Foodpanda aesthetic glow
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 58,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'ORDER PLACED!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 10),

              // Thank you message
              Text(
                'Thank you for your order.\nBrew & Bite is getting it ready for you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 28),

              // Order Number Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.softIce,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.softBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order Number',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      orderNumber,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.electricBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentStatus,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Estimated time indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    size: 18,
                    color: AppColors.electricBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated preparation time: ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '15–25 mins',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // TRACK ORDER Button
              CustomButton(
                text: 'TRACK ORDER',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(
                        orderId: orderNumber,
                        orderNumber: orderNumber,
                      ),
                    ),
                  );
                },
                icon: Icons.navigation_rounded,
              ),
              const SizedBox(height: 12),

              // BACK TO HOME Button
              CustomButton(
                text: 'BACK TO HOME',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                isOutlined: true,
                icon: Icons.home_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
