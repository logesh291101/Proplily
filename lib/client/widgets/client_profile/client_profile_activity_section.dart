import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/models/client_home_dashboard.dart';
import 'package:proplilly/client/widgets/client_home/client_home_activity_timeline.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

/// Recent profile activity timeline.
class ProfileActivitySection extends StatelessWidget {
  const ProfileActivitySection({super.key, required this.activities});

  final List<ActivityItem> activities;

  @override
  Widget build(BuildContext context) {
    return ModernSectionCard(
      title: 'Recent Updates',
      titleIcon: Icons.timeline_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your latest account and property activity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HomeActivityTimeline(activities: activities),
        ],
      ),
    );
  }
}
