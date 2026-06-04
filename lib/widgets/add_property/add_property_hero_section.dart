import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Gradient hero banner for [AddPropertyScreen].
class AddPropertyHeroSection extends StatelessWidget {
  const AddPropertyHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = (MediaQuery.sizeOf(context).height * 0.27).clamp(210.0, 250.0);

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
            right: -48,
            top: -20,
            child: Icon(
              Icons.apartment_rounded,
              size: 140,
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 24,
            child: Icon(
              Icons.landscape_rounded,
              size: 90,
              color: AppColors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 40,
            child: Icon(
              Icons.location_city_rounded,
              size: 56,
              color: AppColors.white.withValues(alpha: 0.12),
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
                          Icons.add_home_work_rounded,
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
                              'Register New Property',
                              style: theme.headlineSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your Indian asset to the PropLilly monitoring '
                              'ecosystem.',
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
