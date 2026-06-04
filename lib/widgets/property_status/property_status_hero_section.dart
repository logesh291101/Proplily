import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Gradient hero banner for [PropertyStatusScreen].
class PropertyStatusHeroSection extends StatelessWidget {
  const PropertyStatusHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = (MediaQuery.sizeOf(context).height * 0.26).clamp(200.0, 240.0);

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: PremiumDecorations.headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -40,
            top: -20,
            child: Icon(
              Icons.insights_rounded,
              size: 130,
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: -24,
            bottom: 28,
            child: Icon(
              Icons.fact_check_outlined,
              size: 80,
              color: AppColors.white.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.white,
                    iconSize: 20,
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: PremiumDecorations.frostedCircle,
                        child: const Icon(
                          Icons.monitor_heart_outlined,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Property Status',
                              style: theme.headlineSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Track current monitoring, report approvals, and '
                              'manager visibility for each property.',
                              style: theme.bodyMedium?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
