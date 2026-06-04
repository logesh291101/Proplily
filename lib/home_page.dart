import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/add_property_screen.dart';
import 'package:proplilly/client_feedback_screen.dart';
import 'package:proplilly/property_status_screen.dart';
import 'package:proplilly/billing_screen.dart';
import 'package:proplilly/login_page.dart';
import 'package:proplilly/providers/home_dashboard_provider.dart';
import 'package:proplilly/client_referral_screen.dart';
import 'package:proplilly/services/logout_service.dart';
import 'package:proplilly/client_support_ticket_screen.dart';
import 'package:proplilly/ticket_list_screen.dart';
import 'package:proplilly/client_profile_screen.dart';
import 'package:proplilly/widgets/home/home_dashboard_body.dart';
import 'package:proplilly/widgets/home/home_welcome_header.dart';
import 'package:proplilly/widgets/premium/premium_error_state.dart';
import 'package:proplilly/widgets/premium/premium_screen_body.dart';
import 'package:proplilly/widgets/proplilly_logo_badge.dart';

/// Main shell after login with premium dashboard UI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeDashboardProvider()..loadDashboard(),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  static const List<({String label, IconData icon})> _menuItems = [
    (label: 'Home', icon: Icons.home),
    (label: 'Add Property', icon: Icons.add_home),
    (label: 'View Property Status', icon: Icons.visibility),
    (label: 'Refer a Friend', icon: Icons.people_alt),
    (label: 'Customer Billing', icon: Icons.receipt_long),
    (label: 'Client Feedback', icon: Icons.feedback),
    (label: 'Raise Support Ticket', icon: Icons.support_agent),
    (label: 'Your Tickets', icon: Icons.confirmation_number_outlined),
    (label: 'My Profile', icon: Icons.person),
    (label: 'Log Out', icon: Icons.logout),
  ];
  static const double _menuIconSize = 22;

  final LogoutService _logoutService = LogoutService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _logoutInProgress = false;
  String? _lastShownError;

  Future<void> _refreshDashboard() async {
    await context.read<HomeDashboardProvider>().refresh();
  }

  void _maybeShowErrorSnackBar(HomeDashboardProvider provider) {
    final message = provider.errorMessage;
    if (message == null ||
        message == _lastShownError ||
        provider.isLoading ||
        !provider.hasData) {
      return;
    }
    _lastShownError = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _onMenuItemTapped(String label) {
    Navigator.of(context).pop();
    switch (label) {
      case 'My Profile':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const ClientProfileScreen()),
        );
      case 'Refer a Friend':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const ClientReferralScreen()),
        );
      case 'Customer Billing':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const BillingScreen(),
          ),
        );
      case 'Raise Support Ticket':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ClientSupportTicketScreen(),
          ),
        );
      case 'Your Tickets':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const TicketListScreen(),
          ),
        );
      case 'Add Property':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const AddPropertyScreen(),
          ),
        );
      case 'View Property Status':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const PropertyStatusScreen(),
          ),
        );
      case 'Client Feedback':
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const ClientFeedbackScreen(),
          ),
        );
      default:
        break;
    }
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
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
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
      ),
      drawer: _buildDrawer(context),
      body: Consumer<HomeDashboardProvider>(
        builder: (context, provider, _) {
          _maybeShowErrorSnackBar(provider);

          if (provider.isLoading && !provider.hasData) {
            return const PremiumScreenBody(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return PremiumScreenBody(
              child: PremiumErrorState(
                message: provider.errorMessage!,
                onRetry: _refreshDashboard,
              ),
            );
          }

          final dashboard = provider.homeDashboard;
          if (dashboard == null) {
            return PremiumScreenBody(
              child: PremiumErrorState(
                message: provider.errorMessage ??
                    'Dashboard data is unavailable.',
                onRetry: _refreshDashboard,
              ),
            );
          }

          return PremiumScreenBody(
            applyTopSpacing: true,
            padding: EdgeInsets.zero,
            child: RefreshIndicator(
              onRefresh: _refreshDashboard,
              color: AppColors.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeWelcomeHeader(firstName: dashboard.firstName),
                  ),
                  SliverToBoxAdapter(
                    child: HomeDashboardBody(dashboard: dashboard),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDark,
                    AppColors.primary,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProplillyLogoBadge(
                    size: (MediaQuery.sizeOf(context).width * 0.28)
                        .clamp(60.0, 80.0),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Menu',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            ..._menuItems.take(_menuItems.length - 1).map(
                  (item) => ListTile(
                    leading: Icon(
                      item.icon,
                      size: _menuIconSize,
                      color: AppColors.primaryDark,
                    ),
                    horizontalTitleGap: 12,
                    minLeadingWidth: 24,
                    title: Text(
                      item.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => _onMenuItemTapped(item.label),
                  ),
                ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                size: _menuIconSize,
                color: AppColors.primaryDark,
              ),
              horizontalTitleGap: 12,
              minLeadingWidth: 24,
              title: const Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              enabled: !_logoutInProgress,
              onTap: _logoutInProgress ? null : _onLogoutTapped,
            ),
          ],
        ),
      ),
    );
  }
}
