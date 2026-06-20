import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/models/client_ticket_extensions.dart';
import 'package:proplilly/client/models/client_tickets_model.dart';
import 'package:proplilly/client/providers/client_ticket_list_provider.dart';
import 'package:proplilly/client/screens/client_ticket_detail_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TicketListProvider()..loadTickets(),
      child: const _TicketListView(),
    );
  }
}

class _TicketListView extends StatelessWidget {
  const _TicketListView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<TicketListProvider>().refresh();
  }

  void _openTicketDetail(BuildContext context, ClientTicketData ticket) {
    final ticketId = ticket.id?.trim();
    if (ticketId == null || ticketId.isEmpty) return;

    final provider = context.read<TicketListProvider>();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<TicketListProvider>.value(
          value: provider,
          child: TicketDetailScreen(ticketId: ticketId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Tickets'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'Your Tickets',
            subtitle: 'Track support requests and view ticket updates.',
            icon: Icons.confirmation_number_outlined,
          ),
          Expanded(
            child: Consumer<TicketListProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && !provider.hasData) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Loading tickets...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.errorMessage != null && !provider.hasData) {
                  return PremiumErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => _refresh(context),
                  );
                }

                final tickets = provider.tickets;

                if (tickets.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontal),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 56,
                                  color: AppColors.primaryLight
                                      .withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No tickets found.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  color: AppColors.primary,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
                    itemCount: tickets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return _TicketListTile(
                        ticket: ticket,
                        onViewDetails: () => _openTicketDetail(context, ticket),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketListTile extends StatelessWidget {
  const _TicketListTile({
    required this.ticket,
    required this.onViewDetails,
  });

  final ClientTicketData ticket;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.28),
        ),
        boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ticket.displaySubject,
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        const SizedBox(height: 8),
          Text(
            ticket.message ?? "",
            style: theme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          // _TicketMetaRow(label: 'Category', value: ticket.displayCategory),
           const SizedBox(height: 8),
          _TicketMetaRow(
            label: 'Created Date',
            value: ticket.formattedCreatedAt,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TicketBadge(
                label: ticket.displayStatus,
                color: ticket.statusColor,
              ),
              const SizedBox(width: 8),
              _TicketBadge(
                label: ticket.displayPriority,
                color: ticket.priorityColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PremiumOutlineButton(
            label: 'View Details',
            onPressed: onViewDetails,
          ),
        ],
      ),
    );
  }
}

class _TicketMetaRow extends StatelessWidget {
  const _TicketMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        style: theme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
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
