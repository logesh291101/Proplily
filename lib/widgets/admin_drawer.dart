import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

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
                  child: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.fullName ?? '',
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
                  icon: Icons.people_outline,
                  title: 'Customers',
                  onTap: () {
                    context.pop();
                    context.push('/admin/customers');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.handyman_outlined,
                  title: 'Coordinators',
                  onTap: () {
                    context.pop();
                    context.push('/admin/coordinators');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_add_alt_1_outlined,
                  title: 'Add Coordinator',
                  onTap: () {
                    context.pop();
                    context.push('/admin/add-coordinator');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.card_membership_outlined,
                  title: 'Plans & Subscribers',
                  onTap: () {
                    context.pop();
                    context.push('/admin/plans-subscribers');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Property Review',
                  onTap: () {
                    context.pop();
                    context.push('/admin/property-review');
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
