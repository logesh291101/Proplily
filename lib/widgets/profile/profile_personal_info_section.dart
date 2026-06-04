import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/user_profile.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Personal information tiles — full name, email, phone.
class ProfilePersonalInfoSection extends StatelessWidget {
  const ProfilePersonalInfoSection({super.key, required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.badge_outlined,
          title: 'Personal Information',
        ),
        const SizedBox(height: 14),
        _InfoTile(
          icon: Icons.person_outline_rounded,
          label: 'Full Name',
          value: profile.name,
          tint: AppColors.primary,
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email Address',
          value: profile.email,
          tint: const Color(0xFF5C6BC0),
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Phone Number',
          value: profile.phoneNumber,
          tint: const Color(0xFF00897B),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: PremiumDecorations.iconTile(AppColors.primary),
          child: Icon(icon, size: 18, color: AppColors.primaryDark),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tint.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: PremiumDecorations.cardShadow(opacity: 0.05),
            ),
            child: Icon(icon, color: tint, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
