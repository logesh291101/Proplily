import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proplilly/client/screens/client_add_property_screen.dart';
import 'package:proplilly/client/models/client_home_dashboard.dart';
import 'package:proplilly/client/providers/client_home_ads_provider.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/widgets/client_home/client_home_account_card.dart';
import 'package:proplilly/client/widgets/client_home/client_home_action_tile.dart';
import 'package:proplilly/client/widgets/client_home/client_home_activity_timeline.dart';
import 'package:proplilly/client/widgets/client_home/client_home_ads_slider.dart';
import 'package:proplilly/client/widgets/client_home/client_home_property_carousel.dart';
import 'package:proplilly/client/widgets/client_home/client_home_section_title.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';

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
          const HomePropertyCarousel(),
          Consumer<ClientHomeAdsProvider>(
            builder: (context, adsProvider, _) {
              if (!adsProvider.hasAds) {
                return const SizedBox.shrink();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  ClientHomeAdsSlider(ads: adsProvider.ads),
                ],
              );
            },
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
          // const HomeSectionTitle(
          //   title: 'Security & Documents',
          //   subtitle:
          //       'Manage your property records, account credentials, and '
          //       'documentation security in one place.',
          //   icon: Icons.security_outlined,
          // ),
          // HomeActionTile(
          //   title: 'My Property Portfolio',
          //   icon: Icons.folder_copy_outlined,
          //   onTap: onPortfolioTap ??
          //       () => _showComingSoon(context, 'Property Portfolio'),
          // ),
         // const SizedBox(height: 12),
          // HomeActionTile(
          //   title: 'Security & Credentials',
          //   icon: Icons.lock_outline_rounded,
          //   onTap: onCredentialsTap ??
          //       () => _showComingSoon(context, 'Security & Credentials'),
          // ),
         // const SizedBox(height: 28),
           Column(
             children: [
               HomeSectionTitle(
                title: 'Activity Timeline',
                subtitle:"Everything that happened on your estate",
                icon: Icons.timeline_outlined,
                         ),
             ],
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
