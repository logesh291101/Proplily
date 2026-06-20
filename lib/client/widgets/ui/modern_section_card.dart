import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Rounded elevated card with optional section title — used across feature screens.
class ModernSectionCard extends StatelessWidget {
  const ModernSectionCard({
    super.key,
    this.title,
    this.titleIcon,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  final String? title;
  final IconData? titleIcon;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.07),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Row(
                children: [
                  if (titleIcon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: PremiumDecorations.iconTile(AppColors.primary),
                      child: Icon(titleIcon, size: 18, color: AppColors.primaryDark),
                    ),
                  if (titleIcon != null) const SizedBox(width: 10),
                  Text(
                    title!,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
