import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/models/client_ticket_extensions.dart';
import 'package:proplilly/client/models/client_tickets_model.dart';
import 'package:proplilly/client/providers/client_ticket_list_provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/modern_info_row.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

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
        actions: ProplillyAppBar.clientActions(),
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
              child: _TicketDetailBody(ticket: ticket),
            ),
    );
  }
}

class _TicketDetailBody extends StatelessWidget {
  const _TicketDetailBody({required this.ticket});

  final ClientTicketData ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final imageUrl = ticket.resolutionImageUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.all(18),
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: [
        //         AppColors.accent.withValues(alpha: 0.5),
        //         AppColors.white,
        //       ],
        //     ),
        //     borderRadius: BorderRadius.circular(20),
        //     border: Border.all(
        //       color: AppColors.primaryLight.withValues(alpha: 0.3),
        //     ),
        //     boxShadow: PremiumDecorations.cardShadow(opacity: 0.06),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'Ticket #${ticket.ticketId}',
        //         style: theme.titleMedium?.copyWith(
        //           fontWeight: FontWeight.w800,
        //           color: AppColors.textPrimary,
        //         ),
        //       ),
        //       const SizedBox(height: 10),
        //       Row(
        //         children: [
        //           _TicketBadge(
        //             label: ticket.displayStatus,
        //             color: ticket.statusColor,
        //           ),
        //           const SizedBox(width: 8),
        //           _TicketBadge(
        //             label: ticket.displayPriority,
        //             color: ticket.priorityColor,
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 18),
        ModernSectionCard(
          title: 'Ticket Information',
          titleIcon: Icons.confirmation_number_outlined,
          child: Column(
            children: [
              ModernInfoRow(
                icon: Icons.subject_outlined,
                label: 'Subject',
                value: ticket.displaySubject,
                showDivider: true,
              ),
              // ModernInfoRow(
              //   icon: Icons.category_outlined,
              //   label: 'Category',
              //   value: ticket.displayCategory,
              //   showDivider: true,
              // ),
              ModernInfoRow(
                icon: Icons.message_outlined,
                label: 'Message',
                value: ticket.displayMessage,
                showDivider: true,
              ),
              // ModernInfoRow(
              //   icon: Icons.flag_outlined,
              //   label: 'Priority',
              //   value: ticket.displayPriority,
              //   showDivider: true,
              // ),
              // ModernInfoRow(
              //   icon: Icons.info_outline_rounded,
              //   label: 'Status',
              //   value: ticket.displayStatus,
              //   showDivider: true,
              // ),
              // ModernInfoRow(
              //   icon: Icons.calendar_today_outlined,
              //   label: 'Created Date',
              //   value: ticket.formattedCreatedAt,
              //   showDivider: true,
              // ),
              // ModernInfoRow(
              //   icon: Icons.schedule_outlined,
              //   label: 'Last Replied At',
              //   value: ticket.formattedLastRepliedAt,
              //   showDivider: true,
              // ),
              // ModernInfoRow(
              //   icon: Icons.reply_outlined,
              //   label: 'Admin Reply',
              //   value: ticket.displayAdminReply,
              //   showDivider: imageUrl != null,
              // ),
              if (imageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resolution Image',
                        style: theme.labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            height: 180,
                            color: AppColors.accent.withValues(alpha: 0.35),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            height: 180,
                            color: AppColors.accent.withValues(alpha: 0.35),
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketBadge extends StatelessWidget {
  const _TicketBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
