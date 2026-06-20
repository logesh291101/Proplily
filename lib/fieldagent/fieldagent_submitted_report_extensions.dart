import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_model.dart';

extension FieldAgentSubmittedReportDataUi on FieldAgentSubmittedReportData {
  String get normalizedReviewStatus =>
      reviewStatus?.trim().toLowerCase() ?? '';

  bool get isPending => normalizedReviewStatus == 'pending';

  bool get isRejected => normalizedReviewStatus == 'rejected';

  bool get isApproved => normalizedReviewStatus == 'approved';

  String get displayReportId {
    final id = reportId?.trim();
    return (id != null && id.isNotEmpty) ? id : '—';
  }

  String get displayPropertyName {
    final name = propertyName?.trim();
    return (name != null && name.isNotEmpty) ? name : '—';
  }

  String get displayLocation {
    final location = geoTag?.trim();
    return (location != null && location.isNotEmpty) ? location : '—';
  }

  String get displayVisitType {
    final type = visitType?.trim();
    return (type != null && type.isNotEmpty) ? type : '—';
  }

  String get reviewStatusLabel {
    final raw = reviewStatus?.trim();
    return (raw != null && raw.isNotEmpty) ? raw : '—';
  }

  Color get reviewStatusColor {
    if (isApproved) return AppColors.success;
    if (isRejected) return AppColors.error;
    if (isPending) return AppColors.warning;
    return AppColors.primaryDark;
  }

  List<String> get imageUrls =>
      FieldAgentSubmittedReportImageParser.parse(propertyImages);

  String get agentRemarks {
    final notes = publicNotes?.trim();
    return (notes != null && notes.isNotEmpty) ? notes : '—';
  }

  String get managerRemarks {
    final comments = managerComments?.trim();
    return (comments != null && comments.isNotEmpty) ? comments : '—';
  }

  bool get hasApprovalInfo =>
      _hasText(managerDecision) ||
      _hasText(managerReviewedBy) ||
      _hasText(managerReviewedAt) ||
      _hasText(adminFinalStatus) ||
      _hasText(adminOverrideNotes) ||
      _hasText(adminReviewedBy) ||
      _hasText(adminReviewedAt);

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class FieldAgentSubmittedReportImageParser {
  FieldAgentSubmittedReportImageParser._();

  static List<String> parse(String? raw) {
    if (raw == null) return [];

    final images = <String>[];

    void addUrl(String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty && !images.contains(trimmed)) {
        images.add(trimmed);
      }
    }

    try {
      if (raw.trim().startsWith('[')) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              addUrl(item['url']?.toString() ?? item['image']?.toString());
            } else {
              addUrl(item?.toString());
            }
          }
        }
      } else if (raw.contains(',')) {
        for (final part in raw.split(',')) {
          addUrl(part);
        }
      } else {
        addUrl(raw);
      }
    } catch (_) {
      addUrl(raw);
    }

    return images;
  }
}

enum SubmittedReportFilter {
  awaitingApprovals,
  rejected,
  approved,
}

extension SubmittedReportFilterX on SubmittedReportFilter {
  String get label {
    switch (this) {
      case SubmittedReportFilter.awaitingApprovals:
        return 'Awaiting Approvals';
      case SubmittedReportFilter.rejected:
        return 'Rejected Reports';
      case SubmittedReportFilter.approved:
        return 'Approved Reports';
    }
  }

  bool matches(FieldAgentSubmittedReportData report) {
    final status = report.normalizedReviewStatus;
    switch (this) {
      case SubmittedReportFilter.awaitingApprovals:
        return status == 'pending';
      case SubmittedReportFilter.rejected:
        return status == 'rejected';
      case SubmittedReportFilter.approved:
        return status == 'approved';
    }
  }
}

String formatSubmittedReportDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw.trim();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = parsed.day.toString().padLeft(2, '0');
  final month = months[parsed.month - 1];
  return '$day $month ${parsed.year}';
}

int compareSubmittedReportsBySubmittedAtDesc(
  FieldAgentSubmittedReportData a,
  FieldAgentSubmittedReportData b,
) {
  final aDate = _parseDate(a.submittedAt);
  final bDate = _parseDate(b.submittedAt);

  if (aDate == null && bDate == null) return 0;
  if (aDate == null) return 1;
  if (bDate == null) return -1;

  return bDate.compareTo(aDate);
}

DateTime? _parseDate(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
