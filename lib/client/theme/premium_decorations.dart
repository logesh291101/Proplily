import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';

/// Shared gradients, shadows, and shapes for premium screens.
class PremiumDecorations {
  PremiumDecorations._();

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
      colors: [
      AppColors.primaryDark,
      AppColors.primary,
      AppColors.primaryLight,
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primaryDark,
      AppColors.primary,
    ],
  );

  static List<BoxShadow> cardShadow({double opacity = 0.10}) => [
        BoxShadow(
          color: AppColors.primaryDark.withValues(alpha: opacity),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static BoxDecoration frostedCircle = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.white.withValues(alpha: 0.18),
    border: Border.all(color: AppColors.white.withValues(alpha: 0.35)),
  );

  static BoxDecoration iconTile(Color tint) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.18),
            tint.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.15)),
      );
}
