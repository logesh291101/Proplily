import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/auth/login_screen.dart';
import 'package:proplilly/auth/logout_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/premium/premium_screen_body.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/fieldagent/providers/fieldagent_dashboard_provider.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedule_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_screen.dart';
import 'package:proplilly/fieldagent/screens/fieldagent_profile_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_raise_ticket_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_referral_screen.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_reports_screen.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_drawer.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_home_hero_section.dart';
import 'package:proplilly/client/widgets/client_home/client_home_section_title.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_home_ads_slider.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_home_property_carousel.dart';
import 'package:proplilly/fieldagent/widgets/fieldagent_home_summary_section.dart';

/// Field Agent home shell with navigation drawer and API dashboard.
class FieldAgentHomeScreen extends StatefulWidget {
  const FieldAgentHomeScreen({super.key});

  @override
  State<FieldAgentHomeScreen> createState() => _FieldAgentHomeScreenState();
}

class _FieldAgentHomeScreenState extends State<FieldAgentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FieldAgentDashboardProvider()..loadDashboard(),
      child: const _FieldAgentHomeView(),
    );
  }
}

class _FieldAgentHomeView extends StatefulWidget {
  const _FieldAgentHomeView();

  @override
  State<_FieldAgentHomeView> createState() => _FieldAgentHomeViewState();
}

class _FieldAgentHomeViewState extends State<_FieldAgentHomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LogoutService _logoutService = LogoutService();

  bool _logoutInProgress = false;

  Future<void> _refreshDashboard() async {
    await context.read<FieldAgentDashboardProvider>().refresh();
  }

  void _onMenuItemTapped(String label) {
    Navigator.of(context).pop();

    if (label == 'Home') {
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() => _activeDrawerRoute = null);
      return;
    }

    final routeKey = _routeKeyForLabel(label);
    final screen = _screenForLabel(label);
    if (routeKey == null || screen == null) {
      return;
    }

    _navigateToScreen(routeKey: routeKey, screen: screen);
  }

  String? _routeKeyForLabel(String label) {
    return switch (label) {
      'My Schedules' => 'field_agent_my_schedules',
      'My Assigned Properties' => 'field_agent_assigned_properties',
      'Submitted Reports' => 'field_agent_submitted_reports',
      'Referrals' => 'field_agent_referrals',
      'Profile' => 'field_agent_profile',
      'Raise Support Ticket' => 'field_agent_raise_ticket',
      _ => null,
    };
  }

  Widget? _screenForLabel(String label) {
    return switch (label) {
      'My Schedules' => const FieldAgentMyScheduleScreen(),
      'My Assigned Properties' => const FieldAgentMyAssignedPropertiesScreen(),
      'Submitted Reports' => const FieldAgentSubmittedReportsScreen(),
      'Referrals' => const FieldAgentReferralScreen(),
      'Profile' => const FieldAgentProfileScreen(),
      'Raise Support Ticket' => const FieldAgentRaiseTicketScreen(),
      _ => null,
    };
  }

  String? _activeDrawerRoute;

  void _navigateToScreen({
    required String routeKey,
    required Widget screen,
  }) {
    if (_activeDrawerRoute == routeKey) {
      return;
    }

    setState(() => _activeDrawerRoute = routeKey);

    Navigator.of(context)
        .push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: routeKey),
        builder: (_) => screen,
      ),
    )
        .whenComplete(() {
      if (mounted && _activeDrawerRoute == routeKey) {
        setState(() => _activeDrawerRoute = null);
      }
    });
  }

  Future<void> _onLogoutTapped() async {
    if (_logoutInProgress) return;
    Navigator.of(context).pop();
    setState(() => _logoutInProgress = true);

    try {
      final cleared = await _logoutService.logout();
      if (!mounted) return;

      if (!cleared) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not clear local account data.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _logoutInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Proplilly'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: ProplillyAppBar.logoActions(),
      ),
      drawer: FieldAgentDrawer(
        onItemSelected: _onMenuItemTapped,
        onLogout: _onLogoutTapped,
        logoutInProgress: _logoutInProgress,
      ),
      body: Consumer<FieldAgentDashboardProvider>(
        builder: (context, provider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const FieldAgentHomeHeroSection(),
              Expanded(
                child: _buildDashboardBody(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardBody(
    BuildContext context,
    FieldAgentDashboardProvider provider,
  ) {
    if (provider.isLoading && !provider.hasData) {
      return const PremiumScreenBody(
        applyTopSpacing: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (provider.errorMessage != null && !provider.hasData) {
      return PremiumScreenBody(
        applyTopSpacing: false,
        child: PremiumErrorState(
          message: provider.errorMessage!,
          onRetry: _refreshDashboard,
        ),
      );
    }

    return PremiumScreenBody(
      applyTopSpacing: false,
      child: RefreshIndicator(
        onRefresh: _refreshDashboard,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              FieldAgentHomeSummarySection(
                scheduledTasksCount: provider.scheduledTasksCount,
                assignedPropertiesCount: provider.assignedPropertiesCount,
              ),
              if (provider.hasAds) ...[
                const SizedBox(height: 20),
                FieldAgentHomeAdsSlider(ads: provider.ads),
              ],
              const SizedBox(height: 20),
              const HomeSectionTitle(
                title: 'Assigned Properties',
                icon: Icons.home_work_outlined,
              ),
              FieldAgentHomePropertyCarousel(
                properties: provider.assignedProperties,
                isLoading:
                    provider.isLoading && provider.assignedPropertiesModel == null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
