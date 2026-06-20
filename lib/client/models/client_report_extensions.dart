import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_report_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';

extension ClientReportDataUi on ClientReportData {
  String? get reportDate => visitDate ?? submittedAt;

  String get formattedReportDate => formatClientReportDate(reportDate);

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
    final normalized = reviewStatus?.trim().toLowerCase() ?? '';
    if (normalized.contains('approv')) return AppColors.success;
    if (normalized.contains('reject')) return AppColors.error;
    if (normalized.contains('pending') || normalized.contains('await')) {
      return AppColors.warning;
    }
    return AppColors.primaryDark;
  }

  List<String> get imageUrls =>
      ClientReportImageParser.parse(propertyImages);

  String get agentRemarks {
    final notes = publicNotes?.trim();
    return (notes != null && notes.isNotEmpty) ? notes : '—';
  }
}

class ClientReportImageParser {
  ClientReportImageParser._();

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

String formatClientReportDate(String? raw) {
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
