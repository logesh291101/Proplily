import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_property_status_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';

/// Card for one property from `GET /user/properties/status`.
class PropertyStatusPropertyCard extends StatelessWidget {
  const PropertyStatusPropertyCard({
    super.key,
    required this.property,
  });

  final ClientPropertyStatus property;

  static String _display(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isNotEmpty ? trimmed : '—';
  }

  static Color _statusColor(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
      case 'authorized':
      case 'approved':
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'in_review':
      case 'review':
        return AppColors.warning;
      case 'inactive':
      case 'suspended':
      case 'rejected':
      case 'unauthorized':
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  static String _accountManagerLine(ClientPropertyStatus property) {
    final name = property.accountManagerName.trim();
    final phone = property.accountManagerPhone.trim();

    if (name.isEmpty && phone.isEmpty) return '—';
    if (name.isNotEmpty && phone.isNotEmpty) return '$name · $phone';
    return name.isNotEmpty ? name : phone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    final propertyName = _display(property.propertyName);
    final monitoringStatus = property.monitoringStatus.trim();
    final statusLabel =
        monitoringStatus.isNotEmpty ? monitoringStatus.toUpperCase() : '—';
    final statusColor = monitoringStatus.isNotEmpty
        ? _statusColor(monitoringStatus)
        : AppColors.textSecondary;

    final rows = <_StatusDetailRowData>[
      _StatusDetailRowData(
        icon: Icons.engineering_outlined,
        label: 'Field Agent',
        value: _display(property.coordinatorName),
      ),
      _StatusDetailRowData(
        icon: Icons.support_agent_outlined,
        label: 'Account Manager',
        value: _accountManagerLine(property),
      ),
      _StatusDetailRowData(
        icon: Icons.history_rounded,
        label: 'Last Visit',
        value: _display(property.lastVisit),
      ),
      _StatusDetailRowData(
        icon: Icons.rate_review_outlined,
        label: 'Review Status',
        value: _display(property.latestReviewStatus),
        showDivider: false,
      ),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.22),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.accent.withValues(alpha: 0.35),
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: PremiumDecorations.iconTile(AppColors.primary),
                  child: const Icon(
                    Icons.home_work_outlined,
                    size: 22,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        propertyName,
                        style: theme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(
              children: [
                for (final row in rows)
                  _StatusDetailRow(
                    icon: row.icon,
                    label: row.label,
                    value: row.value,
                    showDivider: row.showDivider,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDetailRowData {
  const _StatusDetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _StatusDetailRow extends StatelessWidget {
  const _StatusDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isEmpty = value == '—';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: PremiumDecorations.iconTile(
                  AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: theme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.bodyMedium?.copyWith(
                        color: isEmpty
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 58,
            endIndent: 10,
            color: AppColors.primaryLight.withValues(alpha: 0.14),
          ),
      ],
    );
  }
}
