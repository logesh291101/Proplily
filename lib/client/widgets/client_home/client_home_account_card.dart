import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/premium/premium_status_chip.dart';

/// Gradient personal account summary card.
class HomeAccountCard extends StatelessWidget {
  const HomeAccountCard({
    super.key,
    required this.plan,
    required this.memberSince,
    required this.planEndDate,
    required this.paymentStatus,
    required this.isPaymentStatusPositive,
  });

  final String plan;
  final String memberSince;
  final String planEndDate;
  final String paymentStatus;
  final bool isPaymentStatusPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: PremiumDecorations.headerGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -12,
            child: Icon(
              Icons.verified_user_rounded,
              size: 88,
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ACCOUNT DETAILS',
                    style: theme.labelSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  // const Spacer(),
                  // PremiumStatusChip(
                  //   label: paymentStatus,
                  //   color: isPaymentStatusPositive
                  //       ? AppColors.success
                  //       : AppColors.warning,
                  //   isPositive: isPaymentStatusPositive,
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoRow(
                icon: Icons.workspace_premium_outlined,
                label: 'Plan',
                value: plan,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.calendar_month_outlined,
                label: 'Member since',
                value: memberSince,
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'Plan ends',
                value: planEndDate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
