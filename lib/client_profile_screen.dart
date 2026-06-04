import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/edit_client_profile_screen.dart';
import 'package:proplilly/billing_screen.dart';
import 'package:proplilly/models/profile_hub.dart';
import 'package:proplilly/providers/client_profile_provider.dart';
import 'package:proplilly/client_support_ticket_screen.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/widgets/premium/premium_error_state.dart';
import 'package:proplilly/widgets/profile/profile_account_section.dart';
import 'package:proplilly/widgets/profile/profile_activity_section.dart';
import 'package:proplilly/widgets/profile/profile_hero_section.dart';
import 'package:proplilly/widgets/profile/profile_personal_info_section.dart';
import 'package:proplilly/widgets/profile/profile_quick_actions.dart';
import 'package:proplilly/widgets/profile/profile_subscription_card.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientProfileProvider()..loadProfile(),
      child: const _ClientProfileView(),
    );
  }
}

class _ClientProfileView extends StatefulWidget {
  const _ClientProfileView();

  @override
  State<_ClientProfileView> createState() => _ClientProfileViewState();
}

class _ClientProfileViewState extends State<_ClientProfileView> {
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEditAvatar() => _showComingSoon('Profile photo editing');

  Future<void> _onEditProfile() async {
    final data = context.read<ClientProfileProvider>().profileData?.data;
    if (data == null) return;

    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditClientProfileScreen(
          initialName: data.name,
          initialPhone: data.phone,
        ),
      ),
    );

    if (updated == true && mounted) {
      await context.read<ClientProfileProvider>().refresh();
    }
  }

  void _onManageSubscription() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const BillingScreen()),
    );
  }

  void _onContactSupport() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ClientSupportTicketScreen()),
    );
  }

  void _onAccountOption(ProfileAccountOption option) {
    _showComingSoon(option.title);
  }

  Future<void> _refresh() async {
    await context.read<ClientProfileProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ClientProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return PremiumErrorState(
              message: provider.errorMessage!,
              onRetry: _refresh,
            );
          }

          final profile = provider.displayProfile;
          if (profile == null) {
            return PremiumErrorState(
              message: provider.errorMessage ?? 'Profile data is unavailable.',
              onRetry: _refresh,
            );
          }

          final horizontal = ScreenSpacing.horizontal(context);

          return Column(
            children: [
              ProfileHeroSection(
                profile: profile,
                onEditAvatar: _onEditAvatar,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height:20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryLight.withValues(alpha: 0.28),
                            ),
                            boxShadow: PremiumDecorations.cardShadow(opacity: 0.08),
                          ),
                          child: ProfilePersonalInfoSection(profile: profile),
                        ),
                       // const SizedBox(height: 20),
                        //ProfileSubscriptionCard(profile: profile),
                       // const SizedBox(height: 20),
                        // ProfileAccountSection(
                        //   options: ProfileHubContent.accountOptions,
                        //   onOptionTap: _onAccountOption,
                        // ),
                       // const SizedBox(height: 20),
                       // ProfileActivitySection(activities: profile.activities),
                         const SizedBox(height: 22),
                        ProfileQuickActions(
                          onEditProfile: _onEditProfile,
                          onManageSubscription: _onManageSubscription,
                          onContactSupport: _onContactSupport,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
