import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Gradient hero banner for [ClientReferralScreen].
class ClientReferralHeroSection extends StatelessWidget {
  const ClientReferralHeroSection({super.key});

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
            top: -30,
            child: Icon(
              Icons.blur_on,
              size: 160,
              color: AppColors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            left: -30,
            bottom: 30,
            child: Icon(
              Icons.blur_on,
              size: 100,
              color: AppColors.white.withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.white,
                        iconSize: 20,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Refer & Grow',
                          style: theme.labelMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
                          Icons.card_giftcard_rounded,
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
                              'Invite & Earn',
                              style: theme.headlineMedium?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Refer your friends and help them discover '
                              'smarter property management.',
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
