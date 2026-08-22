import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_referral_list_extensions.dart';
import 'package:proplilly/client/models/client_referral_list_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

class ClientMyReferralCard extends StatelessWidget {
  const ClientMyReferralCard({
    super.key,
    required this.referral,
  });

  final ClientReferral referral;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReferralInfoSection(
            title: 'Referred User',
            children: [
              Text(
                referral.displayReferredName,
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                referral.displayReferredEmail,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: AppColors.primaryLight.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 16),
          _ReferralInfoSection(
            title: 'Referred Date',
            children: [
              Text(
                referral.displayJoinedAt,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: AppColors.primaryLight.withValues(alpha: 0.18),
          ),
          const SizedBox(height: 16),
          _ReferralInfoSection(
            title: 'Status',
            children: [
              Text(
                referral.displayStatusLabel,
                style: theme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralInfoSection extends StatelessWidget {
  const _ReferralInfoSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
