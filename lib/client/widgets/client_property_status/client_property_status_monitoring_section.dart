import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/models/client_property_status_legacy.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/widgets/premium/premium_status_chip.dart';
import 'package:proplilly/client/widgets/client_property_status/client_property_status_monitoring_tile.dart';

/// Monitoring details grid with report approval highlight.
class PropertyStatusMonitoringSection extends StatelessWidget {
  const PropertyStatusMonitoringSection({
    super.key,
    required this.monitoring,
  });

  final PropertyMonitoringDetails monitoring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final report = monitoring.reportStatus;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: PremiumDecorations.iconTile(AppColors.primary),
                child: const Icon(
                  Icons.groups_outlined,
                  size: 20,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitoring Details',
                      style: theme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Field visits, managers & report visibility',
                      style: theme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 520 ? 2 : 1;
              final tileWidth = crossAxisCount == 2
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: PropertyStatusMonitoringTile(
                      icon: Icons.engineering_outlined,
                      label: 'Field Agent',
                      value: monitoring.fieldAgent,
                      iconTint: const Color(0xFF5C6BC0),
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: PropertyStatusMonitoringTile(
                      icon: Icons.event_outlined,
                      label: 'Next Visit',
                      value: monitoring.nextVisit,
                      iconTint: AppColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: PropertyStatusMonitoringTile(
                      icon: Icons.support_agent_outlined,
                      label: 'Account Manager',
                      value: monitoring.accountManager,
                      iconTint: AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: PropertyStatusMonitoringTile(
                      icon: Icons.history_rounded,
                      label: 'Last Visit',
                      value: monitoring.lastVisit,
                      iconTint: const Color(0xFF00897B),
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _ReportStatusRow(report: report),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportStatusRow extends StatelessWidget {
  const _ReportStatusRow({required this.report});

  final PropertyReportStatus report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: report.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: report.color.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: report.color.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: PremiumDecorations.iconTile(report.color),
            child: Icon(
              Icons.assignment_turned_in_outlined,
              color: report.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Status',
                  style: theme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Latest inspection report',
                  style: theme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PremiumStatusChip(
            label: report.label,
            color: report.color,
            isPositive: report.isPositive,
          ),
        ],
      ),
    );
  }
}
