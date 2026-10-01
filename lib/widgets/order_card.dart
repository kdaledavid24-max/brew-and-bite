import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

/// Aesthetic Foodpanda-style Order Card widget
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final Widget? trailingAction;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppColors.getStatusColor(order.status);
    final statusIcon = AppColors.getStatusIcon(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.softBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order Number & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.receipt_rounded,
                          size: 18,
                          color: AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        order.orderNumber,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.midnightNavy,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(order.status, statusColor, statusIcon),
                ],
              ),
              const SizedBox(height: 12),

              // Date & Customer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.softIce,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.orderType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: order.orderType == AppConstants.orderTypeDelivery
                            ? AppColors.electricBlue
                            : AppColors.orangeAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Customer Name & Contact
              Text(
                order.customerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.midnightNavy,
                ),
              ),
              const SizedBox(height: 4),

              // Items breakdown summary
              Text(
                order.itemsSummary,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Footer: Total & View button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${AppConstants.currencySymbol}${order.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ],
                  ),
                  if (trailingAction != null)
                    trailingAction!
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.navyCard
                            : AppColors.softIce,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'VIEW ORDER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.electricBlue,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.electricBlue,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
