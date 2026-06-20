import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Elevated rounded card with optional section title.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    this.title,
    this.titleIcon,
    this.child,
    this.children = const [],
    this.padding = const EdgeInsets.fromLTRB(18, 18, 18, 8),
    this.margin,
  });

  final String? title;
  final IconData? titleIcon;
  final Widget? child;
  final List<Widget> children;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final body = child ?? Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: PremiumDecorations.cardShadow(),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            body,
          ],
        ),
      ),
    );
  }
}
