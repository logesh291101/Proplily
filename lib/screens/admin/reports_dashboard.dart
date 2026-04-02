import 'package:flutter/material.dart';
import '../../theme/auth_theme.dart';

class ReportsDashboard extends StatelessWidget {
  const ReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('System Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChartSection(
              'Visit Performance',
              'Completion rate over the last 30 days',
              [
                _buildBar('Mon', 0.8, Colors.green),
                _buildBar('Tue', 0.9, Colors.green),
                _buildBar('Wed', 0.6, Colors.orange),
                _buildBar('Thu', 0.85, Colors.green),
                _buildBar('Fri', 0.7, Colors.green),
                _buildBar('Sat', 0.4, Colors.red),
                _buildBar('Sun', 0.5, Colors.orange),
              ],
            ),
            const SizedBox(height: 32),
            _buildChartSection(
              'Revenue Growth',
              'Monthly subscription revenue',
              [
                _buildBar('Jan', 0.4, AuthTheme.primary),
                _buildBar('Feb', 0.6, AuthTheme.primary),
                _buildBar('Mar', 0.75, AuthTheme.primary),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatGrid(),
            const SizedBox(height: 32),
            _buildRecentActivity(),
          ],
        ),
      ),
    ));
  }

  Widget _buildChartSection(String title, String subtitle, List<Widget> bars) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double percentage, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 100 * percentage,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: AuthTheme.textSecondary)),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMiniStat('Total Properties', '124', Icons.home_outlined),
        _buildMiniStat('Active Coordinators', '18', Icons.people_outline),
        _buildMiniStat('Total Revenue', '₹2.4L', Icons.payments_outlined),
        _buildMiniStat('Issues Resolved', '92%', Icons.check_circle_outline),
      ],
    );
  }

  Widget _buildMiniStat(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AuthTheme.primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 10, color: AuthTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent System Events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildActivityItem('User "Rajesh" subscribed to Premium Plan', '2 hours ago'),
        _buildActivityItem('Property "Green Heights" verified by Admin', '5 hours ago'),
        _buildActivityItem('Coordinator "Rahul" completed 5 visits today', 'Today'),
      ],
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AuthTheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(activity, style: const TextStyle(fontSize: 12))),
          Text(time, style: const TextStyle(fontSize: 10, color: AuthTheme.textSecondary)),
        ],
      ),
    );
  }
}
