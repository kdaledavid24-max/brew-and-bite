import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'main_screen.dart';
import 'order_details_screen.dart';

/// Order success screen shown after placing an order
class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;

  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),
              // Success message
              Text(
                'ORDER PLACED!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for ordering from\n${AppConstants.appName}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Order number
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Order #$orderNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.goldAccent : AppColors.coffeeBrown,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Estimated time
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated preparation time:',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '15–25 minutes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const Spacer(),
              // Action buttons
              CustomButton(
                text: 'VIEW ORDER',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsScreen(orderNumber: orderNumber),
                    ),
                  );
                },
                icon: Icons.receipt_long,
              ),
              const SizedBox(height: 12),
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
                icon: Icons.home,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
