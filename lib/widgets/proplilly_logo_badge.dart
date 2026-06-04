import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';

/// PropLilly logo with frosted container — matches [LoginPage] header styling.
class ProplillyLogoBadge extends StatelessWidget {
  const ProplillyLogoBadge({
    super.key,
    this.size,
  });

  /// Outer square size; when null, scales from screen width like the login page.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoSize = size ?? (screenWidth * 0.16).clamp(78.0, 118.0);
    final outerRadius = (logoSize * 0.22).clamp(16.0, 24.0);
    final innerRadius = (logoSize * 0.16).clamp(12.0, 18.0);
    final padding = (logoSize * 0.09).clamp(8.0, 12.0);

    return Container(
      height: logoSize,
      width: logoSize,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.28),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Image.asset(
          'assets/proplilly_logo.jfif',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.home_work_rounded,
            size: (logoSize * 0.48).clamp(36.0, 58.0),
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
