import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Vertical order-status timeline.
///
/// This widget is shared by the customer's Order Details screen and the
/// admin's Order Tracking screen, so both sides always show exactly the
/// same progress view for an order.
///
/// Pickup orders:   Pending -> Confirmed -> Preparing -> Ready -> Completed
/// Delivery orders: Pending -> Confirmed -> Preparing -> Out for Delivery -> Delivered
class StatusTracker extends StatelessWidget {
  final String status;
  final String orderType;

  const StatusTracker({
    super.key,
    required this.status,
    required this.orderType,
  });

  /// The status steps for this order type
  List<String> get _statuses {
    if (orderType == AppConstants.orderTypeDelivery) {
      return [
        AppConstants.statusPending,
        AppConstants.statusConfirmed,
        AppConstants.statusPreparing,
        AppConstants.statusOutForDelivery,
        AppConstants.statusDelivered,
      ];
    }
    return [
      AppConstants.statusPending,
      AppConstants.statusConfirmed,
      AppConstants.statusPreparing,
      AppConstants.statusReady,
      AppConstants.statusCompleted,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCancelled = status == AppConstants.statusCancelled;

    // Cancelled orders show a simple notice instead of the timeline
    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'This order has been cancelled.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      );
    }

    final steps = _statuses;
    final currentIndex = steps.indexOf(status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++)
            _buildStep(
              status: steps[i],
              isCompleted: i <= currentIndex,
              isCurrent: i == currentIndex,
              isLast: i == steps.length - 1,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  /// One row of the timeline (circle + connecting line + label)
  Widget _buildStep({
    required String status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
    required bool isDark,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : (isDark ? AppColors.darkSurface : AppColors.warmBeige),
                  shape: BoxShape.circle,
                  border: isCompleted
                      ? null
                      : Border.all(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.success
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 30,
                  color: isCompleted
                      ? AppColors.success
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.warmBeige),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? (isDark ? AppColors.darkText : AppColors.lightText)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
