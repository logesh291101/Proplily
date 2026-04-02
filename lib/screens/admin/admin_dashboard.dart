import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../services/property_service.dart';
import '../../models/property_model.dart';
import '../../widgets/admin_drawer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _totalCustomers = 0;
  int _totalProperties = 0;
  int _activeMonitoring = 0;
  int _completedVisits = 0;
  int _pendingVisits = 0;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final customers = await UserService().getCustomers();
    final properties = await PropertyService().getProperties();
    
    if (mounted) {
      setState(() {
        _totalCustomers = customers.length;
        _totalProperties = properties.length;
        
        // Simulating analytics
        _activeMonitoring = properties.where((p) => p.status == PropertyStatus.approved).length;
        _pendingVisits = properties.where((p) => p.status == PropertyStatus.pendingVerification).length;
        _completedVisits = 12; // Mock completed visits derived from closed reports
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AuthTheme.scaffoldBg,
        drawer: const AdminDrawer(),
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
          ],
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Overview Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary)),
                  const SizedBox(height: 16),
                  
                  // Primary Metrics Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                    children: [
                      _buildMetricCard('Total Customers', '$_totalCustomers', Icons.people_alt, Colors.blue),
                      _buildMetricCard('Total Properties', '$_totalProperties', Icons.home_work, Colors.indigo),
                      _buildMetricCard('Active Monitoring', '$_activeMonitoring', Icons.remove_red_eye, Colors.green),
                      _buildMetricCard('Completed Visits', '$_completedVisits', Icons.task_alt, Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMetricCard('Pending Visits', '$_pendingVisits', Icons.pending_actions, Colors.orange, fullWidth: true),
                  
                  const SizedBox(height: 32),
                  const Text('Platform Engagement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary)),
                  const SizedBox(height: 16),
                  
                  // Platform Engagement List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildEngagementRow(Icons.login, 'Logins Today', '142', Colors.blue),
                        const Divider(height: 1),
                        _buildEngagementRow(Icons.bolt, 'Active Sessions', '28', Colors.amber),
                        const Divider(height: 1),
                        _buildEngagementRow(Icons.person_add, 'New Sign-ups (24h)', '12', Colors.green),
                        const Divider(height: 1),
                        _buildEngagementRow(Icons.radar, 'Pending Property Monitoring', '$_pendingVisits', Colors.orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              if (fullWidth)
                 Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          if (!fullWidth)
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 13, color: AuthTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEngagementRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AuthTheme.textPrimary))),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary)),
        ],
      ),
    );
  }
}
