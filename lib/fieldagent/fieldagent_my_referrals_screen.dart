import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/fieldagent/providers/fieldagent_my_referrals_provider.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_my_referral_card.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_screen_scaffold.dart';

class FieldAgentMyReferralsScreen extends StatelessWidget {
  const FieldAgentMyReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FieldAgentMyReferralsProvider()..loadReferrals(),
      child: const _FieldAgentMyReferralsView(),
    );
  }
}

class _FieldAgentMyReferralsView extends StatelessWidget {
  const _FieldAgentMyReferralsView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<FieldAgentMyReferralsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return FieldAgentScreenScaffold(
      title: 'My Referrals',
      subtitle: 'Track all your submitted referrals.',
      icon: Icons.people_alt_outlined,
      body: Consumer<FieldAgentMyReferralsProvider>(
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

          final referrals = provider.referrals;

          if (referrals.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.12),
                  const _FieldAgentMyReferralsEmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            color: AppColors.primary,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
              itemCount: referrals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return FieldAgentMyReferralCard(referral: referrals[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FieldAgentMyReferralsEmptyState extends StatelessWidget {
  const _FieldAgentMyReferralsEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 42,
                color: AppColors.primaryDark.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No referrals found.',
              textAlign: TextAlign.center,
              style: theme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
