import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/billing_details.dart';
import 'package:proplilly/models/client_billing_model.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/widgets/payment_status_chip.dart';

/// Rich subscription summary card with plan and dates from API.
class BillingSubscriptionCard extends StatelessWidget {
  const BillingSubscriptionCard({super.key, required Object billing})
      : _billingInput = billing;

  final Object _billingInput;

  BillingHistory get _billing {
    final input = _billingInput;
    if (input is BillingHistory) return input;
    if (input is BillingDetails) return billingHistoryFromLegacy(input);
    throw ArgumentError(
      'billing must be BillingHistory or BillingDetails, '
      'was ${input.runtimeType}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final billing = _billing;
    final paymentStatus = PaymentStatus.fromString(billing.paymentStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark.withValues(alpha: 0.92),
            AppColors.primary,
            const Color(0xFF9B5CAD),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.white,
                  size: 26,
                ),
              ),
              const Spacer(),
              PaymentStatusChip(status: paymentStatus),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Plan Details',
            style: theme.labelMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            billing.planName,
            style: theme.headlineSmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            billing.planPrice,
            style: theme.titleLarge?.copyWith(
              color: AppColors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _MembershipRow(
                  icon: Icons.play_circle_outline_rounded,
                  label: 'Start Date',
                  value: billing.startDate,
                ),
                const SizedBox(height: 12),
                _MembershipRow(
                  icon: Icons.stop_circle_outlined,
                  label: 'End Date',
                  value: billing.endDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipRow extends StatelessWidget {
  const _MembershipRow({
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
        Icon(icon, color: AppColors.white.withValues(alpha: 0.85), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.78),
                ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
