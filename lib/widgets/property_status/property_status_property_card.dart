import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/client_property_status_model.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/widgets/premium/premium_status_chip.dart';

/// Card for one property from `GET /user/properties/status`.
class PropertyStatusPropertyCard extends StatelessWidget {
  const PropertyStatusPropertyCard({
    super.key,
    required this.property,
  });

  final ClientPropertyStatusItem property;

  /// Reads a model field without crashing on stale hot-reload instances.
  static String _safeString(String Function() read) {
    try {
      return read();
    } catch (_) {
      return '';
    }
  }

  static String _displayLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return t;
    if (t.length == 1) return t.toUpperCase();
    return '${t[0].toUpperCase()}${t.substring(1).toLowerCase()}';
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

  static bool _isPositiveStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'active':
      case 'authorized':
      case 'approved':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    final propertyName = _safeString(() => property.propertyName);
    final propertyType = _safeString(() => property.propertyType);
    final address = _safeString(() => property.address);
    final city = _safeString(() => property.city);
    final monitoringStatus = _safeString(() => property.monitoringStatus);
    final authorizationStatus =
        _safeString(() => property.authorizationStatus);

    final monitoringLabel = _displayLabel(monitoringStatus);
    final authorizationLabel = _displayLabel(authorizationStatus);
    final typeLabel = _displayLabel(propertyType);

    final addressParts = [address.trim(), city.trim()].where((s) => s.isNotEmpty);
    final locationLine = addressParts.join(', ');

    final monitoringColor = _statusColor(monitoringStatus);
    final authorizationColor = _statusColor(authorizationStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            propertyName,
            style: theme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            typeLabel,
            style: theme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (locationLine.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: AppColors.primaryDark.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationLine,
                    style: theme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _StatusRow(
            label: 'Monitoring',
            chipLabel: monitoringLabel,
            color: monitoringColor,
            isPositive: _isPositiveStatus(monitoringStatus),
          ),
          const SizedBox(height: 12),
          _StatusRow(
            label: 'Authorization',
            chipLabel: authorizationLabel,
            color: authorizationColor,
            isPositive: _isPositiveStatus(authorizationStatus),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.chipLabel,
    required this.color,
    required this.isPositive,
  });

  final String label;
  final String chipLabel;
  final Color color;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: chipLabel.isEmpty
                ? Text(
                    '—',
                    style: theme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : PremiumStatusChip(
                    label: chipLabel,
                    color: color,
                    isPositive: isPositive,
                  ),
          ),
        ),
      ],
    );
  }
}
