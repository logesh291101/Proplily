import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/auth/login_screen.dart';
import 'package:proplilly/auth/logout_service.dart';
import 'package:proplilly/client/services/client_delete_account_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_profile/client_profile_delete_account_section.dart';
import 'package:proplilly/client/widgets/client_profile/client_profile_hero_section.dart';
import 'package:proplilly/client/widgets/client_profile/client_profile_personal_info_section.dart';
import 'package:proplilly/client/widgets/client_profile/client_profile_quick_actions.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/fieldagent/providers/fieldagent_profile_provider.dart';

class FieldAgentProfileScreen extends StatelessWidget {
  const FieldAgentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FieldAgentProfileProvider()..loadProfile(),
      child: const _FieldAgentProfileView(),
    );
  }
}

class _FieldAgentProfileView extends StatefulWidget {
  const _FieldAgentProfileView();

  @override
  State<_FieldAgentProfileView> createState() => _FieldAgentProfileViewState();
}

class _FieldAgentProfileViewState extends State<_FieldAgentProfileView> {
  final _deleteAccountService = ClientDeleteAccountService();
  final _logoutService = LogoutService();

  bool _isDeleting = false;
  bool _isCancelling = false;

  void _showApiMessage(String message) {
    final text = message.trim();
    if (text.isEmpty) return;
    Fluttertoast.showToast(msg: text);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEditAvatar() => _showComingSoon('Profile photo editing');

  void _onEditProfile() => _showComingSoon('Edit profile');

  void _onManageSubscription() => _showComingSoon('Subscription management');

  void _onContactSupport() => _showComingSoon('Contact support');

  Future<void> _refresh() async {
    await context.read<FieldAgentProfileProvider>().refresh();
  }

  Future<void> _onDeleteAccountTapped() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final result = await _deleteAccountService.deleteAccount();
    if (!mounted) return;

    setState(() => _isDeleting = false);

    switch (result) {
      case DeleteAccountSuccess(:final message):
        _showApiMessage(message);
        final cleared = await _logoutService.logout();
        if (!mounted) return;
        if (!cleared) {
          Fluttertoast.showToast(
            msg: 'Could not clear local account data.',
          );
          return;
        }
        Navigator.of(context).pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      case DeleteAccountFailure(:final message):
        _showApiMessage(message);
    }
  }

  Future<void> _onCancelDeleteAccountTapped() async {
    setState(() => _isCancelling = true);
    final result = await _deleteAccountService.cancelDeleteAccount();
    if (!mounted) return;

    setState(() => _isCancelling = false);

    switch (result) {
      case DeleteAccountSuccess(:final message):
        _showApiMessage(message);
        await context.read<FieldAgentProfileProvider>().refresh();
      case DeleteAccountFailure(:final message):
        _showApiMessage(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.heroOverlay(),
      body: Consumer<FieldAgentProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.28),
                            ),
                            boxShadow:
                                PremiumDecorations.cardShadow(opacity: 0.08),
                          ),
                          child: ProfilePersonalInfoSection(profile: profile),
                        ),
                        const SizedBox(height: 22),
                        ProfileQuickActions(
                          onEditProfile: _onEditProfile,
                          onManageSubscription: _onManageSubscription,
                          onContactSupport: _onContactSupport,
                        ),
                        const SizedBox(height: 20),
                        ProfileDeleteAccountSection(
                          isDeletionScheduled: provider.isDeletionScheduled,
                          isDeleting: _isDeleting,
                          isCancelling: _isCancelling,
                          onDeleteAccount: _onDeleteAccountTapped,
                          onCancelDeletion: _onCancelDeleteAccountTapped,
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
