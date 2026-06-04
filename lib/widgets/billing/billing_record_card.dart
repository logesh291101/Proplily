import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/billing_details.dart';
import 'package:proplilly/models/client_billing_model.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Compact card for one billing record from the API.
class BillingRecordCard extends StatelessWidget {
  const BillingRecordCard({super.key, required this.billing});

  final BillingHistory billing;

  Color _statusColor(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
      case 'completed':
      case 'paid':
      case 'success':
        return AppColors.success;
      case 'failed':
      case 'expired':
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentStatus = PaymentStatus.fromString(billing.paymentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailRow(
            left: _CompactDetail(label: 'Plan Name', value: billing.planName),
            right: _CompactDetail(label: 'Plan Price', value: billing.planPrice),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            left: _CompactDetail(
              label: 'Status',
              value: billing.status,
              valueColor: _statusColor(billing.status),
            ),
            right: _CompactDetail(
              label: 'Payment Status',
              value: billing.paymentStatus,
              valueColor: paymentStatus.highlightColor,
            ),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            left: _CompactDetail(label: 'Start Date', value: billing.startDate),
            right: _CompactDetail(label: 'End Date', value: billing.endDate),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }
}

class _CompactDetail extends StatelessWidget {
  const _CompactDetail({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.bodySmall?.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
