import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/widgets/premium/premium_buttons.dart';

/// Primary and secondary profile actions.
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({
    super.key,
    required this.onEditProfile,
    required this.onManageSubscription,
    required this.onContactSupport,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onManageSubscription;
  final VoidCallback onContactSupport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumPrimaryButton(
          label: 'Edit Profile',
          icon: Icons.edit_outlined,
          onPressed: onEditProfile,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isAccent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: isAccent
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isAccent
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.primaryLight.withValues(alpha: 0.4),
            ),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.05),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isAccent ? AppColors.primary : AppColors.primaryDark,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
