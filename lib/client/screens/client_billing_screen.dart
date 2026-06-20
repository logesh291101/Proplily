import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/providers/client_billing_provider.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_billing/client_billing_hero_section.dart';
import 'package:proplilly/client/widgets/client_billing/client_billing_record_card.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BillingProvider()..loadBilling(),
      child: const _BillingView(),
    );
  }
}

class _BillingView extends StatelessWidget {
  const _BillingView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<BillingProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: Consumer<BillingProvider>(
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

          final records = provider.billingRecords;
          if (records.isEmpty) {
            return PremiumErrorState(
              message: provider.errorMessage ?? 'Billing data is unavailable.',
              onRetry: () => _refresh(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            color: AppColors.primary,
            child: Column(
              children: [
                const BillingHeroSection(),
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      ScreenSpacing.floatingCardOverlap(context),
                      horizontal,
                      32,
                    ),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < records.length - 1 ? 12 : 0,
                        ),
                        child: BillingRecordCard(billing: records[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
