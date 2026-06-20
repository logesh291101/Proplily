import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';

/// Dashboard content for [HomePage] (mapped from [ClientDashboardModel]).
class HomeDashboard {
  const HomeDashboard({
    required this.userName,
    required this.plan,
    required this.memberSince,
    required this.planEndDate,
    required this.paymentStatus,
    required this.totalProperties,
    required this.activities,
  });

  final String userName;
  final String plan;
  final String memberSince;
  final String planEndDate;
  final String paymentStatus;
  final int totalProperties;
  final List<ActivityItem> activities;

  bool get isPaymentStatusPositive {
    final normalized = paymentStatus.toLowerCase();
    return normalized.contains('active') ||
        normalized.contains('paid') ||
        normalized.contains('success');
  }

  String get firstName {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'there';
    return parts.first;
  }

  String get propertiesLabel =>
      totalProperties == 1 ? 'property' : 'properties';
}

/// A single entry in the personal activity timeline.
class ActivityItem {
  const ActivityItem({
    required this.dateLabel,
    required this.title,
    required this.description,
    required this.icon,
    this.link,
    this.accentColor = AppColors.primary,
  });

  final String dateLabel;
  final String title;
  final String description;
  final IconData icon;
  final String? link;
  final Color accentColor;
}
