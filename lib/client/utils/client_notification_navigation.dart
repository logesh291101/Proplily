import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_notification_model.dart';
import 'package:proplilly/client/screens/client_my_properties_screen.dart';
import 'package:proplilly/client/screens/client_property_status_screen.dart';
import 'package:proplilly/client/screens/client_support_ticket_screen.dart';
import 'package:proplilly/client/screens/client_ticket_list_screen.dart';
import 'package:proplilly/client/screens/client_visit_report_details_screen.dart';
import 'package:proplilly/client/screens/client_visit_reports_screen.dart';

/// Routes client notifications to the appropriate screen using API data.
abstract final class ClientNotificationNavigation {
  static void open(BuildContext context, NotificationData notification) {
    final title = notification.title?.trim().toLowerCase() ?? '';
    final redirect = notification.redirectUrl?.trim();

    final reportId = _extractReportId(redirect);
    if (reportId != null) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ClientVisitReportDetailsScreen(reportId: reportId),
        ),
      );
      return;
    }

    if (_matches(title, ['property assigned', 'assigned property'])) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const ClientMyPropertiesScreen(),
        ),
      );
      return;
    }

    if (_matches(title, ['task scheduled', 'schedule'])) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const PropertyStatusScreen(),
        ),
      );
      return;
    }

    if (_matches(title, ['report approved', 'report rejected', 'visit report'])) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const ClientVisitReportsScreen(),
        ),
      );
      return;
    }

    if (_matches(title, ['ticket update', 'ticket', 'support ticket'])) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => const ClientSupportTicketScreen(),
        ),
      );
      return;
    }

    if (redirect != null && redirect.isNotEmpty) {
      if (redirect.contains('ticket')) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const TicketListScreen(),
          ),
        );
        return;
      }
      if (redirect.contains('property')) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ClientMyPropertiesScreen(),
          ),
        );
        return;
      }
      if (redirect.contains('report')) {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ClientVisitReportsScreen(),
          ),
        );
        return;
      }
    }
  }

  static bool _matches(String title, List<String> keywords) {
    return keywords.any(title.contains);
  }

  static String? _extractReportId(String? redirectUrl) {
    if (redirectUrl == null || redirectUrl.trim().isEmpty) return null;

    final uri = Uri.tryParse(redirectUrl);
    if (uri != null) {
      final queryId = uri.queryParameters['report_id'] ??
          uri.queryParameters['reportId'];
      if (queryId != null && queryId.trim().isNotEmpty) {
        return queryId.trim();
      }

      final segments = uri.pathSegments;
      final reportIndex = segments.indexWhere(
        (segment) => segment.toLowerCase().contains('visit-report'),
      );
      if (reportIndex >= 0 && reportIndex + 1 < segments.length) {
        return segments[reportIndex + 1].trim();
      }
    }

    final match = RegExp(
      r'report[_-]?id[=:/](\d+)',
      caseSensitive: false,
    ).firstMatch(redirectUrl);
    return match?.group(1)?.trim();
  }
}
