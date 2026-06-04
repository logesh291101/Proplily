import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/client_tickets_model.dart';
import 'package:proplilly/providers/ticket_list_provider.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/widgets/premium/premium_error_state.dart';
import 'package:proplilly/widgets/ui/modern_info_row.dart';

class TicketDetailScreen extends StatelessWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TicketListProvider>();
    final ticket = provider.ticketById(ticketId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ticket Details'),
      ),
      body: ticket == null
          ? PremiumErrorState(
              message: provider.errorMessage ?? 'Ticket not found.',
              onRetry: () => provider.refresh(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                ScreenSpacing.horizontal(context),
                16,
                ScreenSpacing.horizontal(context),
                32,
              ),
              child: _TicketDetailCard(ticket: ticket),
            ),
    );
  }
}

class _TicketDetailCard extends StatelessWidget {
  const _TicketDetailCard({required this.ticket});

  final ClientTicket ticket;

  static const _fields = <_TicketDetailField>[
    _TicketDetailField(
      key: _FieldKey.subject,
      label: 'Subject',
      icon: Icons.subject_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.category,
      label: 'Category',
      icon: Icons.category_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.message,
      label: 'Message',
      icon: Icons.message_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.priority,
      label: 'Priority',
      icon: Icons.flag_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.adminReply,
      label: 'Admin Reply',
      icon: Icons.reply_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.lastRepliedAt,
      label: 'Last Replied At',
      icon: Icons.schedule_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.createdAt,
      label: 'Created At',
      icon: Icons.calendar_today_outlined,
    ),
    _TicketDetailField(
      key: _FieldKey.updatedAt,
      label: 'Updated At',
      icon: Icons.update_outlined,
    ),
  ];

  String? _valueFor(_FieldKey key) {
    switch (key) {
      case _FieldKey.subject:
        return ticket.subject;
      case _FieldKey.category:
        return ticket.category;
      case _FieldKey.message:
        return ticket.message;
      case _FieldKey.priority:
        return ticket.priority;
      case _FieldKey.adminReply:
        return ticket.adminReply;
      case _FieldKey.lastRepliedAt:
        return ticket.lastRepliedAt;
      case _FieldKey.createdAt:
        return ticket.createdAt;
      case _FieldKey.updatedAt:
        return ticket.updatedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleFields = _fields
        .map((field) => (field: field, value: _valueFor(field.key)))
        .where((entry) => entry.value != null)
        .toList();

    if (visibleFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      child: Column(
        children: [
          for (var i = 0; i < visibleFields.length; i++)
            ModernInfoRow(
              icon: visibleFields[i].field.icon,
              label: visibleFields[i].field.label,
              value: visibleFields[i].value!,
              showDivider: i < visibleFields.length - 1,
            ),
        ],
      ),
    );
  }
}

enum _FieldKey {
  subject,
  category,
  message,
  priority,
  adminReply,
  lastRepliedAt,
  createdAt,
  updatedAt,
}

class _TicketDetailField {
  const _TicketDetailField({
    required this.key,
    required this.label,
    required this.icon,
  });

  final _FieldKey key;
  final String label;
  final IconData icon;
}
