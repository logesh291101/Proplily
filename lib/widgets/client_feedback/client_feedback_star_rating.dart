import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Interactive 1–5 star rating control.
class ClientFeedbackStarRating extends StatelessWidget {
  const ClientFeedbackStarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;

  static const int maxStars = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: PremiumDecorations.iconTile(AppColors.primary),
              child: const Icon(
                Icons.star_outline_rounded,
                size: 18,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Rating',
              style: theme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxStars, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= rating;

            return Padding(
              //padding: EdgeInsets.only(right: index < maxStars - 1 ? 10 : 0),
              padding:EdgeInsets.all(2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onRatingChanged(starIndex),
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFB300).withValues(alpha: 0.18)
                          : AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFFFB300).withValues(alpha: 0.6)
                            : AppColors.primaryLight.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: isSelected
                          ? const Color(0xFFF9A825)
                          : AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '(1 to 5 stars)',
            style: theme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (rating > 0) ...[
          const SizedBox(height: 6),
          Center(
            child: Text(
              '$rating of $maxStars selected',
              style: theme.labelMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
