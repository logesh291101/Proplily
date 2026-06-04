import 'package:flutter/material.dart';
import 'package:proplilly/add_property_screen.dart';
import 'package:proplilly/models/home_dashboard.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/widgets/home/home_account_card.dart';
import 'package:proplilly/widgets/home/home_action_tile.dart';
import 'package:proplilly/widgets/home/home_activity_timeline.dart';
import 'package:proplilly/widgets/home/home_properties_card.dart';
import 'package:proplilly/widgets/home/home_section_title.dart';
import 'package:proplilly/widgets/premium/premium_buttons.dart';

/// Scrollable home dashboard sections below the welcome header.
class HomeDashboardBody extends StatelessWidget {
  const HomeDashboardBody({
    super.key,
    required this.dashboard,
    this.onRegisterProperty,
    this.onPortfolioTap,
    this.onCredentialsTap,
  });

  final HomeDashboard dashboard;
  final VoidCallback? onRegisterProperty;
  final VoidCallback? onPortfolioTap;
  final VoidCallback? onCredentialsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.translate(
            offset: Offset(0, -ScreenSpacing.floatingCardOverlap(context)),
            child: HomeAccountCard(
              plan: dashboard.plan,
              memberSince: dashboard.memberSince,
              planEndDate: dashboard.planEndDate,
              paymentStatus: dashboard.paymentStatus,
              isPaymentStatusPositive: dashboard.isPaymentStatusPositive,
            ),
          ),
          const HomeSectionTitle(
            title: 'My Properties',
            icon: Icons.home_work_outlined,
          ),
          HomePropertiesCard(
            totalUnits: dashboard.totalProperties,
            propertiesLabel: dashboard.propertiesLabel,
          ),
          const SizedBox(height: 20),
          PremiumPrimaryButton(
            label: 'Register New Property',
            icon: Icons.add_rounded,
            onPressed: onRegisterProperty ??
                () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddPropertyScreen()));
                },
          ),
          const SizedBox(height: 28),
          const HomeSectionTitle(
            title: 'Security & Documents',
            subtitle:
                'Manage your property records, account credentials, and '
                'documentation security in one place.',
            icon: Icons.security_outlined,
          ),
          // HomeActionTile(
          //   title: 'My Property Portfolio',
          //   icon: Icons.folder_copy_outlined,
          //   onTap: onPortfolioTap ??
          //       () => _showComingSoon(context, 'Property Portfolio'),
          // ),
          const SizedBox(height: 12),
          // HomeActionTile(
          //   title: 'Security & Credentials',
          //   icon: Icons.lock_outline_rounded,
          //   onTap: onCredentialsTap ??
          //       () => _showComingSoon(context, 'Security & Credentials'),
          // ),
          const SizedBox(height: 28),
          const HomeSectionTitle(
            title: 'Personal Activity Timeline',
            icon: Icons.timeline_outlined,
          ),
          HomeActivityTimeline(activities: dashboard.activities),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
