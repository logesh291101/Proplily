import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';

class HelperDashboard extends StatelessWidget {
  const HelperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Helper Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.fullName ?? 'Helper'}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AuthTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your assigned property monitoring tasks here.',
              style: TextStyle(
                fontSize: 16,
                color: AuthTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'My Assignments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AuthTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 0, // Will be populated with actual assignments
                itemBuilder: (context, index) {
                  return const SizedBox.shrink();
                },
                shrinkWrap: true,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: AuthTheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No properties assigned yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AuthTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
