import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/widgets/proplilly_logo_badge.dart';

/// Navigation drawer for the Field Agent module.
class FieldAgentDrawer extends StatelessWidget {
  const FieldAgentDrawer({
    super.key,
    required this.onItemSelected,
    required this.onLogout,
    this.selectedLabel,
    this.logoutInProgress = false,
  });

  final ValueChanged<String> onItemSelected;
  final VoidCallback onLogout;
  final String? selectedLabel;
  final bool logoutInProgress;

  static const List<({String label, IconData icon})> menuItems = [
    (label: 'Home', icon: Icons.calendar_month_outlined),
    (label: 'My Schedules', icon: Icons.calendar_month_outlined),
    (label: 'My Assigned Properties', icon: Icons.home_work_outlined),
    (label: 'Submitted Reports', icon: Icons.description_outlined),
    (label: 'Referrals', icon: Icons.people_alt_outlined),
    (label: 'Profile', icon: Icons.person_outline_rounded),
    (label: 'Raise Support Ticket', icon: Icons.support_agent_outlined),
  ];

  static const double _menuIconSize = 22;

  @override
  Widget build(BuildContext context) {
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
                    'Field Agent',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            ...menuItems.map(
              (item) {
                final isSelected = item.label != 'Home' &&
                    item.label == selectedLabel;
                return ListTile(
                  leading: Icon(
                    item.icon,
                    size: _menuIconSize,
                    color: isSelected ? AppColors.primary : AppColors.primaryDark,
                  ),
                  horizontalTitleGap: 12,
                  minLeadingWidth: 24,
                  selected: isSelected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  onTap: () => onItemSelected(item.label),
                );
              },
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
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              enabled: !logoutInProgress,
              onTap: logoutInProgress ? null : onLogout,
            ),
          ],
        ),
      ),
    );
  }
}
