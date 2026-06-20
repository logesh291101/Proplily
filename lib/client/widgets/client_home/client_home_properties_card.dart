import 'package:flutter/material.dart';
import 'package:proplilly/client/screens/client_my_properties_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Statistics card for portfolio property count.
class HomePropertiesCard extends StatelessWidget {
  const HomePropertiesCard({
    super.key,
    required this.totalUnits,
    required this.propertiesLabel,
  });

  final int totalUnits;
  final String propertiesLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap:() {
        Navigator.push(context, MaterialPageRoute(builder:(context) => ClientMyPropertiesScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: PremiumDecorations.cardShadow(),
          border: Border.all(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: PremiumDecorations.iconTile(AppColors.primary),
              child: const Icon(
                Icons.apartment_rounded,
                color: AppColors.primaryDark,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Units',
                    style: theme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalUnits',
                    style: theme.displaySmall?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You have $totalUnits $propertiesLabel in your portfolio.',
                    style: theme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
