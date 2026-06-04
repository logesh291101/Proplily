import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Displays referral code from API — title "Your Referral Code".
class ClientReferralCodeCard extends StatelessWidget {
  const ClientReferralCodeCard({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.referralCode,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? referralCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFB74D).withValues(alpha: 0.35),
            AppColors.primary.withValues(alpha: 0.25),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.6),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.1),
      ),
      child: _buildContent(theme),
    );
  }

  Widget _buildContent(TextTheme theme) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (errorMessage != null) {
      return Text(
        errorMessage!,
        style: theme.bodyMedium?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Referral Code',
          style: theme.labelLarge?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        if (referralCode != null) ...[
          const SizedBox(height: 10),
          Text(
            referralCode!,
            style: theme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
