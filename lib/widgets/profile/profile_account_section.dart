import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/profile_hub.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/widgets/ui/modern_section_card.dart';

/// Account & security option tiles.
class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({
    super.key,
    required this.options,
    required this.onOptionTap,
  });

  final List<ProfileAccountOption> options;
  final ValueChanged<ProfileAccountOption> onOptionTap;

  @override
  Widget build(BuildContext context) {
    return ModernSectionCard(
      title: 'Account & Security',
      titleIcon: Icons.security_outlined,
      child: Column(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _AccountOptionTile(
              option: options[i],
              onTap: () => onOptionTap(options[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccountOptionTile extends StatelessWidget {
  const _AccountOptionTile({
    required this.option,
    required this.onTap,
  });

  final ProfileAccountOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: option.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: option.color.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: PremiumDecorations.cardShadow(opacity: 0.04),
                ),
                child: Icon(option.icon, color: option.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
