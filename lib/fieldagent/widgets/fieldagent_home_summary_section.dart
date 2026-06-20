import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_screen.dart';

/// Scheduled tasks and assigned properties summary cards.
class FieldAgentHomeSummarySection extends StatelessWidget {
  const FieldAgentHomeSummarySection({
    super.key,
    required this.scheduledTasksCount,
    required this.assignedPropertiesCount,
  });

  final int scheduledTasksCount;
  final int assignedPropertiesCount;

  void _openSchedules(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FieldAgentMyScheduleScreen(),
      ),
    );
  }

  void _openAssignedProperties(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FieldAgentMyAssignedPropertiesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Scheduled Tasks',
            count: scheduledTasksCount,
            icon: Icons.calendar_month_outlined,
            accent: AppColors.primary,
            onTap: () => _openSchedules(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Assigned Properties',
            count: assignedPropertiesCount,
            icon: Icons.home_work_outlined,
            accent: AppColors.primaryDark,
            onTap: () => _openAssignedProperties(context),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.28),
            ),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: PremiumDecorations.iconTile(accent),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: theme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
