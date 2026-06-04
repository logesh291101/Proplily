import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Gradient hero for [BillingScreen].
class BillingHeroSection extends StatelessWidget {
  const BillingHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final height = (MediaQuery.sizeOf(context).height * 0.24).clamp(190.0, 230.0);

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
        children: [
          Positioned(
            right: -36,
            top: -24,
            child: Icon(
              Icons.blur_on,
              size: 150,
              color: AppColors.white.withValues(alpha: 0.07),
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
                        width: 60,
                        height: 60,
                        decoration: PremiumDecorations.frostedCircle,
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billing & Subscription',
                              style: theme.headlineSmall?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Manage your plans, transactions, and payment '
                              'activity securely.',
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
