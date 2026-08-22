import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/providers/client_my_referrals_provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_referral/client_my_referral_card.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

class ClientMyReferralsScreen extends StatelessWidget {
  const ClientMyReferralsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientMyReferralsProvider()..loadReferrals(),
      child: const _ClientMyReferralsView(),
    );
  }
}

class _ClientMyReferralsView extends StatelessWidget {
  const _ClientMyReferralsView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<ClientMyReferralsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Referrals'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'My Referrals',
            subtitle: 'Track all your submitted referrals.',
            icon: Icons.people_alt_outlined,
          ),
          Expanded(
            child: Consumer<ClientMyReferralsProvider>(
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
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.12,
                        ),
                        const _MyReferralsEmptyState(),
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
                      return ClientMyReferralCard(referral: referrals[index]);
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

class _MyReferralsEmptyState extends StatelessWidget {
  const _MyReferralsEmptyState();

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
