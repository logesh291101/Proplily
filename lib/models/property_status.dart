import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';

/// Monitoring lifecycle status for a registered property.
enum PropertyMonitoringStatus {
  active,
  pending,
  inactive,
  suspended;

  String get label {
    switch (this) {
      case PropertyMonitoringStatus.active:
        return 'Active';
      case PropertyMonitoringStatus.pending:
        return 'Pending';
      case PropertyMonitoringStatus.inactive:
        return 'Inactive';
      case PropertyMonitoringStatus.suspended:
        return 'Suspended';
    }
  }

  Color get color {
    switch (this) {
      case PropertyMonitoringStatus.active:
        return AppColors.success;
      case PropertyMonitoringStatus.pending:
        return AppColors.warning;
      case PropertyMonitoringStatus.inactive:
        return AppColors.textSecondary;
      case PropertyMonitoringStatus.suspended:
        return AppColors.error;
    }
  }

  bool get isPositive => this == PropertyMonitoringStatus.active;
}

/// Report approval state shown on the status screen.
enum PropertyReportStatus {
  approved,
  pending,
  rejected;

  String get label {
    switch (this) {
      case PropertyReportStatus.approved:
        return 'Approved ✓';
      case PropertyReportStatus.pending:
        return 'Pending Review';
      case PropertyReportStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case PropertyReportStatus.approved:
        return AppColors.success;
      case PropertyReportStatus.pending:
        return AppColors.warning;
      case PropertyReportStatus.rejected:
        return AppColors.error;
    }
  }

  bool get isPositive => this == PropertyReportStatus.approved;
}

/// Field-level monitoring details for [PropertyStatusScreen].
class PropertyMonitoringDetails {
  const PropertyMonitoringDetails({
    required this.fieldAgent,
    required this.nextVisit,
    required this.accountManager,
    required this.lastVisit,
    required this.reportStatus,
  });

  final String fieldAgent;
  final String nextVisit;
  final String accountManager;
  final String lastVisit;
  final PropertyReportStatus reportStatus;
}

/// Full property status payload for the status screen.
class PropertyStatusDetails {
  const PropertyStatusDetails({
    required this.propertyName,
    required this.monitoringStatus,
    required this.monitoring,
  });

  final String propertyName;
  final PropertyMonitoringStatus monitoringStatus;
  final PropertyMonitoringDetails monitoring;
}
