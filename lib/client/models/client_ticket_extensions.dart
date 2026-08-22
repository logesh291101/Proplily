import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_support_ticket_model.dart';
import 'package:proplilly/client/models/client_tickets_model.dart';
import 'package:proplilly/client/theme/app_colors.dart';

/// Maps legacy list items to [ClientSupportTicket] after model migrations / hot reload.
ClientSupportTicket clientSupportTicketFromLegacy(ClientTicketData data) {
  return ClientSupportTicket(
    id: data.id?.trim() ?? '',
    userId: data.userId?.trim() ?? '',
    subject: data.subject?.trim() ?? '',
    category: data.category?.trim() ?? '',
    message: data.message?.trim() ?? '',
    status: data.status?.trim() ?? '',
    priority: data.priority?.trim() ?? '',
    adminReply: data.adminReply,
    resolutionImage: data.resolutionImage,
    lastRepliedAt: data.lastRepliedAt,
    createdAt: data.createdAt?.trim() ?? '',
    updatedAt: data.updatedAt?.trim() ?? '',
    resolutionMessage: data.resolutionMessage,
    reopenComment: data.reopenComment,
    forwardedBy: data.forwardedBy,
  );
}

List<ClientSupportTicket> normalizeSupportTicketList(List<dynamic> raw) {
  if (raw.isEmpty) return <ClientSupportTicket>[];

  return raw.map((ticket) {
    if (ticket is ClientSupportTicket) return ticket;
    if (ticket is ClientTicketData) {
      return clientSupportTicketFromLegacy(ticket);
    }
    throw StateError('Unexpected ticket type: ${ticket.runtimeType}');
  }).toList();
}

extension ClientSupportTicketUi on ClientSupportTicket {
  String get ticketId => id.trim().isNotEmpty ? id.trim() : '—';

  String get displaySubject {
    final value = subject.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displayCategory {
    final value = category.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displayMessage {
    final value = message.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displayStatus {
    final value = status.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displayPriority {
    final value = priority.trim();
    return value.isNotEmpty ? value : '—';
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
    final normalized = status.trim().toLowerCase();
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
    final normalized = priority.trim().toLowerCase();
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
