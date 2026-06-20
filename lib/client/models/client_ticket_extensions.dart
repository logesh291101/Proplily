import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_tickets_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';

extension ClientTicketDataUi on ClientTicketData {
  String get ticketId => id?.trim().isNotEmpty == true ? id!.trim() : '—';

  String get displaySubject {
    final value = subject?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get displayCategory {
    final value = category?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get displayMessage {
    final value = message?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get displayStatus {
    final value = status?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get displayPriority {
    final value = priority?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get displayAdminReply {
    final value = adminReply?.trim();
    return (value != null && value.isNotEmpty) ? value : '—';
  }

  String get formattedCreatedAt => formatClientTicketDate(createdAt);

  String get formattedUpdatedAt => formatClientTicketDate(updatedAt);

  String get formattedLastRepliedAt => formatClientTicketDate(lastRepliedAt);

  String? get resolutionImageUrl {
    final value = resolutionImage?.trim();
    return (value != null && value.isNotEmpty) ? value : null;
  }

  Color get statusColor {
    final normalized = status?.trim().toLowerCase() ?? '';
    if (normalized.contains('open') || normalized.contains('new')) {
      return AppColors.primary;
    }
    if (normalized.contains('progress') || normalized.contains('pending')) {
      return AppColors.warning;
    }
    if (normalized.contains('resolved') ||
        normalized.contains('closed') ||
        normalized.contains('complete')) {
      return AppColors.success;
    }
    if (normalized.contains('reject') || normalized.contains('cancel')) {
      return AppColors.error;
    }
    return AppColors.primaryDark;
  }

  Color get priorityColor {
    final normalized = priority?.trim().toLowerCase() ?? '';
    if (normalized.contains('high') || normalized.contains('urgent')) {
      return AppColors.error;
    }
    if (normalized.contains('medium') || normalized.contains('normal')) {
      return AppColors.warning;
    }
    if (normalized.contains('low')) {
      return AppColors.success;
    }
    return AppColors.primaryDark;
  }
}

String formatClientTicketDate(String? raw) {
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
