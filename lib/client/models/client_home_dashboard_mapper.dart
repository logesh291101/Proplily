// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:proplilly/client/theme/app_colors.dart';
// import 'package:proplilly/client/models/Model/clientDashboard_model.dart';
// import 'package:proplilly/client/models/client_home_dashboard.dart';
//
// /// Maps [ClientDashboardModel] API payloads to [HomeDashboard] for the home UI.
// abstract final class HomeDashboardMapper {
//   static final DateFormat _activityDateFormat = DateFormat('MMM dd, yyyy');
//   static final DateFormat _memberSinceFormat = DateFormat('MMM yyyy');
//   static final DateFormat _planEndFormat = DateFormat('MMM dd, yyyy');
//
//   static HomeDashboard toHomeDashboard(ClientDashboardModel model) {
//     final data = model.data;
//     final user = data.user;
//     final plan = data.currentPlan;
//
//     return HomeDashboard(
//       userName: user.name.trim().isEmpty ? 'Guest' : user.name.trim(),
//       plan: plan.planName.trim().isEmpty ? '—' : plan.planName.trim(),
//       memberSince: _memberSinceFormat.format(user.createdAt),
//       planEndDate: _planEndFormat.format(plan.endDate),
//       paymentStatus: _formatPaymentStatus(plan.paymentStatus),
//       totalProperties: data.stats.propertyCount,
//       activities: data.recentActivities.map(_mapActivity).toList(),
//     );
//   }
//
//   static String _formatPaymentStatus(String raw) {
//     final trimmed = raw.trim();
//     if (trimmed.isEmpty) return 'Unknown';
//     return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
//   }
//
//   static ActivityItem _mapActivity(RecentActivity activity) {
//     final link = activity.redirectUrl;
//     final linkStr = link is String && link.trim().isNotEmpty ? link.trim() : null;
//
//     return ActivityItem(
//       dateLabel: _activityDateFormat.format(activity.createdAt),
//       title: activity.title.trim(),
//       description: activity.message.trim(),
//       icon: _iconForTitle(activity.title),
//       link: linkStr,
//       accentColor: _accentForTitle(activity.title),
//     );
//   }
//
//   static IconData _iconForTitle(String title) {
//     final lower = title.toLowerCase();
//     if (lower.contains('visit') || lower.contains('report')) {
//       return Icons.fact_check_outlined;
//     }
//     if (lower.contains('property') || lower.contains('plot')) {
//       return Icons.home_work_outlined;
//     }
//     if (lower.contains('inspection')) {
//       return Icons.assignment_outlined;
//     }
//     if (lower.contains('ticket') || lower.contains('support')) {
//       return Icons.support_agent_outlined;
//     }
//     if (lower.contains('profile')) {
//       return Icons.person_outline_rounded;
//     }
//     if (lower.contains('billing') || lower.contains('payment')) {
//       return Icons.receipt_long_outlined;
//     }
//     return Icons.notifications_outlined;
//   }
//
//   static Color _accentForTitle(String title) {
//     final lower = title.toLowerCase();
//     if (lower.contains('visit') || lower.contains('approved')) {
//       return AppColors.success;
//     }
//     if (lower.contains('ticket') || lower.contains('support')) {
//       return AppColors.warning;
//     }
//     if (lower.contains('inspection')) {
//       return const Color(0xFF5C6BC0);
//     }
//     return AppColors.primary;
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/models/Model/clientDashboard_model.dart';
import 'package:proplilly/client/models/client_home_dashboard.dart';

/// Maps [ClientDashboardModel] API payloads to [HomeDashboard] for the home UI.
abstract final class HomeDashboardMapper {
  static final DateFormat _activityDateFormat =
  DateFormat('MMM dd, yyyy');

  static final DateFormat _memberSinceFormat =
  DateFormat('MMM yyyy');

  static final DateFormat _planEndFormat =
  DateFormat('MMM dd, yyyy');

  static HomeDashboard toHomeDashboard(
      ClientDashboardModel model,
      ) {
    final data = model.data;
    final user = data.user;
    final plan = data.currentPlan;

    return HomeDashboard(
      userName: user.name.trim().isEmpty
          ? 'Guest'
          : user.name.trim(),

      plan: plan.planName.trim().isEmpty
          ? '—'
          : plan.planName.trim(),

      memberSince: _formatDate(
        user.createdAt,
        _memberSinceFormat,
      ),

      planEndDate: _formatDate(
        plan.endDate,
        _planEndFormat,
      ),

      paymentStatus: _formatPaymentStatus(
        plan.paymentStatus,
      ),

      totalProperties: data.stats.propertyCount,

      activities: data.recentActivities
          .map(_mapActivity)
          .toList(),
    );
  }

  /// Safely parses and formats an API date.
  ///
  /// Returns '—' when the API value is null, empty,
  /// or contains an invalid date.
  static String _formatDate(
      String? raw,
      DateFormat format,
      ) {
    if (raw == null || raw.trim().isEmpty) {
      return '—';
    }

    final parsed = DateTime.tryParse(raw.trim());

    if (parsed == null) {
      return '—';
    }

    return format.format(parsed);
  }

  static String _formatPaymentStatus(String raw) {
    final trimmed = raw.trim();

    if (trimmed.isEmpty) {
      return 'Unknown';
    }

    return trimmed[0].toUpperCase() +
        trimmed.substring(1).toLowerCase();
  }

  static ActivityItem _mapActivity(
      RecentActivity activity,
      ) {
    final link = activity.redirectUrl.trim();

    final linkStr = link.isNotEmpty ? link : null;

    return ActivityItem(
      dateLabel: _formatDate(
        activity.createdAt,
        _activityDateFormat,
      ),

      title: activity.title.trim().isEmpty
          ? 'Notification'
          : activity.title.trim(),

      description: activity.message.trim(),

      icon: _iconForTitle(activity.title),

      link: linkStr,

      accentColor: _accentForTitle(
        activity.title,
      ),
    );
  }

  static IconData _iconForTitle(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('visit') ||
        lower.contains('report')) {
      return Icons.fact_check_outlined;
    }

    if (lower.contains('property') ||
        lower.contains('plot')) {
      return Icons.home_work_outlined;
    }

    if (lower.contains('inspection')) {
      return Icons.assignment_outlined;
    }

    if (lower.contains('ticket') ||
        lower.contains('support')) {
      return Icons.support_agent_outlined;
    }

    if (lower.contains('profile')) {
      return Icons.person_outline_rounded;
    }

    if (lower.contains('billing') ||
        lower.contains('payment')) {
      return Icons.receipt_long_outlined;
    }

    return Icons.notifications_outlined;
  }

  static Color _accentForTitle(String title) {
    final lower = title.toLowerCase();

    if (lower.contains('visit') ||
        lower.contains('approved')) {
      return AppColors.success;
    }

    if (lower.contains('ticket') ||
        lower.contains('support')) {
      return AppColors.warning;
    }

    if (lower.contains('inspection')) {
      return const Color(0xFF5C6BC0);
    }

    return AppColors.primary;
  }
}