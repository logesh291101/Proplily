import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Compact monitoring info tile with icon, label, and value.
class PropertyStatusMonitoringTile extends StatelessWidget {
  const PropertyStatusMonitoringTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconTint = AppColors.primary,
    this.valueColor,
    this.trailing,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconTint;
  final Color? valueColor;
  final Widget? trailing;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.success.withValues(alpha: 0.06)
            : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? AppColors.success.withValues(alpha: 0.28)
              : AppColors.primaryLight.withValues(alpha: 0.32),
        ),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: PremiumDecorations.iconTile(iconTint),
                child: Icon(icon, color: AppColors.primaryDark, size: 20),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: theme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.titleSmall?.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
