import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/screens/client_request_additional_service_screen.dart';
import 'package:proplilly/client/providers/client_additional_services_provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_additional_services/client_additional_service_card.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

class ClientAdditionalServicesScreen extends StatelessWidget {
  const ClientAdditionalServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientAdditionalServicesProvider()..loadAdditionalServices(),
      child: const _ClientAdditionalServicesView(),
    );
  }
}

class _ClientAdditionalServicesView extends StatelessWidget {
  const _ClientAdditionalServicesView();

  Future<void> _refresh(BuildContext context) async {
    await context.read<ClientAdditionalServicesProvider>().refresh();
  }

  Future<void> _openRequestService(BuildContext context) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const ClientRequestAdditionalServiceScreen(),
      ),
    );

    if (submitted == true && context.mounted) {
      await _refresh(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        //title: const Text('Additional Services'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'Additional Services',
            subtitle: 'Track your requests for specialized services.',
            icon: Icons.home_repair_service_outlined,
          ),
          Expanded(
            child: Consumer<ClientAdditionalServicesProvider>(
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

                final services = provider.services;

                return RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  color: AppColors.primary,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
                    children: [
                      PremiumPrimaryButton(
                        label: 'Request Service',
                        icon: Icons.add_circle_outline_rounded,
                        onPressed: () => _openRequestService(context),
                      ),
                      const SizedBox(height: 20),
                      if (services.isEmpty)
                        _AdditionalServicesEmptyState(
                          topSpacing:
                              MediaQuery.sizeOf(context).height * 0.08,
                        )
                      else
                        ...[
                          for (var i = 0; i < services.length; i++) ...[
                            ClientAdditionalServiceCard(service: services[i]),
                            if (i < services.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                    ],
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

class _AdditionalServicesEmptyState extends StatelessWidget {
  const _AdditionalServicesEmptyState({required this.topSpacing});

  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(top: topSpacing),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_repair_service_outlined,
              size: 42,
              color: AppColors.primaryDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No additional service requests found.',
            textAlign: TextAlign.center,
            style: theme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
