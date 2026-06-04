import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/widgets/premium/premium_buttons.dart';

/// Quick action buttons for billing screen.
class BillingQuickActions extends StatelessWidget {
  const BillingQuickActions({
    super.key,
    required this.onDownloadInvoice,
    required this.onViewHistory,
    required this.onUpgradePlan,
  });

  final VoidCallback onDownloadInvoice;
  final VoidCallback onViewHistory;
  final VoidCallback onUpgradePlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumPrimaryButton(
          label: 'Download Invoice',
          icon: Icons.download_rounded,
          onPressed: onDownloadInvoice,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionChip(
                label: 'Billing History',
                icon: Icons.history_rounded,
                onTap: onViewHistory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionChip(
                label: 'Upgrade Plan',
                icon: Icons.trending_up_rounded,
                onTap: onUpgradePlan,
                isAccent: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isAccent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isAccent
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAccent
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.primaryLight.withValues(alpha: 0.4),
            ),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.04),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isAccent ? AppColors.primary : AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
