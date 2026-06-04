import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/client_tickets_model.dart';
import 'package:proplilly/providers/ticket_list_provider.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/ticket_detail_screen.dart';
import 'package:proplilly/widgets/premium/premium_error_state.dart';

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

  void _openTicketDetail(BuildContext context, ClientTicket ticket) {
    final provider = context.read<TicketListProvider>();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<TicketListProvider>.value(
          value: provider,
          child: TicketDetailScreen(ticketId: ticket.id),
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
      ),
      body: Consumer<TicketListProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.25),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: provider.ticketsModel?.message.trim().isNotEmpty ==
                              true
                          ? Text(
                              provider.ticketsModel!.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            )
                          : Icon(
                              Icons.inbox_outlined,
                              size: 56,
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.6),
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
                  onTap: () => _openTicketDetail(context, ticket),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TicketListTile extends StatelessWidget {
  const _TicketListTile({
    required this.ticket,
    required this.onTap,
  });

  final ClientTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryLight.withValues(alpha: 0.28),
            ),
            boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ticket.subject != null)
                        Text(
                          'Subject: ${ticket.subject}',
                          style: theme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (ticket.subject != null && ticket.category != null)
                        const SizedBox(height: 8),
                      if (ticket.category != null)
                        Text(
                          'Category: ${ticket.category}',
                          style: theme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
