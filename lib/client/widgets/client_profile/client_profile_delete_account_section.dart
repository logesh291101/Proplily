import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Delete / cancel-delete account actions on the profile screen.
class ProfileDeleteAccountSection extends StatelessWidget {
  const ProfileDeleteAccountSection({
    super.key,
    required this.isDeletionScheduled,
    required this.isDeleting,
    required this.isCancelling,
    required this.onDeleteAccount,
    required this.onCancelDeletion,
  });

  final bool isDeletionScheduled;
  final bool isDeleting;
  final bool isCancelling;
  final VoidCallback? onDeleteAccount;
  final VoidCallback? onCancelDeletion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account Settings',
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          if (!isDeletionScheduled)
            _AccountActionButton(
              label: isDeleting ? 'Deleting...' : 'Delete Account',
              icon: Icons.delete_outline_rounded,
              foregroundColor: AppColors.error,
              borderColor: AppColors.error.withValues(alpha: 0.45),
              isLoading: isDeleting,
              onPressed: isDeleting || isCancelling ? null : onDeleteAccount,
            ),
          if (isDeletionScheduled) ...[
            Text(
              'Account deletion is scheduled.',
              style: theme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            _AccountActionButton(
              label: isCancelling ? 'Cancelling...' : 'Cancel Delete Account',
              icon: Icons.undo_rounded,
              foregroundColor: AppColors.primaryDark,
              borderColor: AppColors.primaryLight.withValues(alpha: 0.7),
              isLoading: isCancelling,
              onPressed: isDeleting || isCancelling ? null : onCancelDeletion,
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountActionButton extends StatelessWidget {
  const _AccountActionButton({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.borderColor,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color borderColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          backgroundColor: AppColors.background,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
