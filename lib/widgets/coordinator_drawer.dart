import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';
import '../../theme/app_theme.dart';

class CoordinatorDrawer extends StatelessWidget {
  const CoordinatorDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 64, bottom: 24, left: 24, right: 24),
            decoration: AuthTheme.heroBackground(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? 'Coordinator',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    context.pop();
                    context.push('/profile');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.monetization_on_outlined,
                  title: 'Plan & Billing',
                  onTap: () {
                    context.pop();
                    context.push('/property-owner/plan-billing');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Support Center',
                  onTap: () {
                    context.pop();
                    context.push('/property-owner/support');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About Us',
                  onTap: () {
                    context.pop();
                    context.push('/about');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.home_work_outlined,
                  title: 'My Properties',
                  onTap: () {
                    context.pop();
                    // Optional constraint to push tab
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.upload_file,
                  title: 'Submit Reports',
                  onTap: () {
                    context.pop();
                    context.push('/coordinator/submit-report');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: Colors.redAccent,
              onTap: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AuthTheme.textPrimary,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
