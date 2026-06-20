import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/providers/client_property_status_provider.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/client_property_status/client_property_status_hero_section.dart';
import 'package:proplilly/client/widgets/client_property_status/client_property_status_property_card.dart';

/// Property monitoring and status list from API.
class PropertyStatusScreen extends StatefulWidget {
  const PropertyStatusScreen({super.key});

  @override
  State<PropertyStatusScreen> createState() => _PropertyStatusScreenState();
}

class _PropertyStatusScreenState extends State<PropertyStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyStatusProvider()..loadPropertyStatus(),
      child: const _PropertyStatusBody(),
    );
  }
}

class _PropertyStatusBody extends StatelessWidget {
  const _PropertyStatusBody();

  Future<void> _refresh(BuildContext context) async {
    await context.read<PropertyStatusProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: Consumer<PropertyStatusProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasProperties) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null && !provider.hasProperties) {
            return PremiumErrorState(
              message: provider.errorMessage!,
              onRetry: () => _refresh(context),
            );
          }

          final properties = provider.properties;
          if (properties.isEmpty) {
            return Column(
              children: [
                const PropertyStatusHeroSection(),
                Expanded(
                  child: _PropertyStatusEmptyState(
                    message: provider.emptyMessage,
                    onRetry: () => _refresh(context),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            color: AppColors.primary,
            child: Column(
              children: [
                const PropertyStatusHeroSection(),
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
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < properties.length - 1 ? 14 : 0,
                        ),
                        child: PropertyStatusPropertyCard(
                          key: ValueKey(
                            properties[index].propertyId.isNotEmpty
                                ? properties[index].propertyId
                                : 'property-$index',
                          ),
                          property: properties[index],
                        ),
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

class _PropertyStatusEmptyState extends StatelessWidget {
  const _PropertyStatusEmptyState({
    this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final apiMessage = message?.trim();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 40,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            if (apiMessage != null && apiMessage.isNotEmpty)
              Text(
                apiMessage,
                textAlign: TextAlign.center,
                style: theme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  side: BorderSide(
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Refresh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
