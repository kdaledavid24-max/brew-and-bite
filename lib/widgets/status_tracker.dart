import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Vertical aesthetic order-status timeline
/// Shared between Customer Order Tracking and Admin Order Tracking
class StatusTracker extends StatelessWidget {
  final String status;
  final String orderType;

  const StatusTracker({
    super.key,
    required this.status,
    required this.orderType,
  });

  bool get isDelivery => orderType == AppConstants.orderTypeDelivery;

  List<_StatusStepConfig> get _steps {
    if (isDelivery) {
      return [
        _StatusStepConfig(
          statusKey: AppConstants.statusPending,
          title: 'Order Placed',
          subtitle: 'Order submitted to Brew & Bite',
          icon: Icons.receipt_long_rounded,
        ),
        _StatusStepConfig(
          statusKey: AppConstants.statusConfirmed,
          title: 'Order Confirmed',
          subtitle: 'Café reviewed and accepted order',
          icon: Icons.check_circle_outline_rounded,
        ),
        _StatusStepConfig(
          statusKey: AppConstants.statusPreparing,
          title: 'Preparing',
          subtitle: 'Kitchen & Barista are preparing items',
          icon: Icons.soup_kitchen_rounded,
        ),
        _StatusStepConfig(
          statusKey: AppConstants.statusOutForDelivery,
          title: 'Out for Delivery',
          subtitle: 'Rider is on the way to your address',
          icon: Icons.delivery_dining_rounded,
        ),
        _StatusStepConfig(
          statusKey: AppConstants.statusDelivered,
          title: 'Delivered',
          subtitle: 'Order successfully delivered',
          icon: Icons.task_alt_rounded,
        ),
      ];
    }

    return [
      _StatusStepConfig(
        statusKey: AppConstants.statusPending,
        title: 'Order Placed',
        subtitle: 'Order received at counter',
        icon: Icons.receipt_long_rounded,
      ),
      _StatusStepConfig(
        statusKey: AppConstants.statusConfirmed,
        title: 'Order Confirmed',
        subtitle: 'Café verified order items',
        icon: Icons.check_circle_outline_rounded,
      ),
      _StatusStepConfig(
        statusKey: AppConstants.statusPreparing,
        title: 'Preparing',
        subtitle: 'Barista is crafting your order',
        icon: Icons.soup_kitchen_rounded,
      ),
      _StatusStepConfig(
        statusKey: AppConstants.statusReady,
        title: 'Ready for Pickup',
        subtitle: 'Ready to collect at the counter',
        icon: Icons.takeout_dining_rounded,
      ),
      _StatusStepConfig(
        statusKey: AppConstants.statusCompleted,
        title: 'Completed',
        subtitle: 'Order fulfilled & enjoyed',
        icon: Icons.task_alt_rounded,
      ),
    ];
  }

  int _getCurrentStepIndex() {
    final lower = status.toLowerCase();
    if (lower == 'pending') return 0;
    if (lower == 'confirmed') return 1;
    if (lower == 'preparing') return 2;
    if (lower == 'ready' || lower == 'out for delivery') return 3;
    if (lower == 'completed' || lower == 'delivered') return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCancelled = status.toLowerCase() == 'cancelled';

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Cancelled',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.error,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'This order was cancelled and will not be prepared.',
                    style: TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _getCurrentStepIndex();
    final steps = _steps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          for (int i = 0; i < steps.length; i++)
            _buildStepRow(
              config: steps[i],
              isPast: i < currentIndex,
              isCurrent: i == currentIndex,
              isLast: i == steps.length - 1,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required _StatusStepConfig config,
    required bool isPast,
    required bool isCurrent,
    required bool isLast,
    required bool isDark,
  }) {
    Color indicatorBg;
    Color indicatorBorder;
    Widget indicatorContent;

    if (isPast) {
      // Completed step: ✓
      indicatorBg = AppColors.success;
      indicatorBorder = AppColors.success;
      indicatorContent = const Icon(
        Icons.check_rounded,
        size: 16,
        color: Colors.white,
      );
    } else if (isCurrent) {
      // Current active step: ●
      indicatorBg = AppColors.electricBlue;
      indicatorBorder = AppColors.electricBlue;
      indicatorContent = Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      );
    } else {
      // Future step: ○
      indicatorBg = isDark ? AppColors.darkBackground : AppColors.softIce;
      indicatorBorder = isDark ? Colors.white24 : AppColors.softBorder;
      indicatorContent = const SizedBox();
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Node & vertical connector line
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: indicatorBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: indicatorBorder, width: 2),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.electricBlue.withValues(alpha: 0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(child: indicatorContent),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isPast
                        ? AppColors.success
                        : (isDark
                            ? Colors.white12
                            : AppColors.softBorder),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Title & subtitle
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        config.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent
                              ? AppColors.electricBlue
                              : (isPast
                                  ? (isDark
                                      ? AppColors.darkText
                                      : AppColors.midnightNavy)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.electricBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'In Progress',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    config.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStepConfig {
  final String statusKey;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatusStepConfig({
    required this.statusKey,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
