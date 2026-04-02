import 'package:flutter/material.dart';
import '../../theme/auth_theme.dart';

class SubscriptionBillingManager extends StatefulWidget {
  const SubscriptionBillingManager({super.key});

  @override
  State<SubscriptionBillingManager> createState() => _SubscriptionBillingManagerState();
}

class _SubscriptionBillingManagerState extends State<SubscriptionBillingManager> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Billing & Subscriptions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AuthTheme.primary,
          unselectedLabelColor: AuthTheme.textSecondary,
          indicatorColor: AuthTheme.primary,
          tabs: const [
            Tab(text: 'Manage Plans'),
            Tab(text: 'Billing History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlanManagement(),
          _buildBillingHistory(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
              backgroundColor: AuthTheme.primary,
            )
          : null,
    ));
  }

  Widget _buildPlanManagement() {
    final plans = [
      {'name': 'Basic Plan', 'price': '₹499/mo', 'status': 'Active', 'features': '2 Properties, Basic Monitoring'},
      {'name': 'Premium Plan', 'price': '₹999/mo', 'status': 'Active', 'features': '5 Properties, Emergency Support'},
      {'name': 'Pro Plan', 'price': '₹1999/mo', 'status': 'Disabled', 'features': 'Unlimited Properties, Full Concierge'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isDisabled = plan['status'] == 'Disabled';
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['name']!,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan['status']!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDisabled ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  plan['price']!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AuthTheme.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  plan['features']!,
                  style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    const Spacer(),
                    Switch(
                      value: !isDisabled,
                      onChanged: (value) {},
                      activeColor: AuthTheme.primary,
                    ),
                    const Text('Enabled', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingHistory() {
    final payments = [
      {'user': 'John Doe', 'amount': '₹999', 'date': '2026-03-01', 'status': 'Success'},
      {'user': 'Jane Smith', 'amount': '₹499', 'date': '2026-02-28', 'status': 'Pending'},
      {'user': 'Suresh Kumar', 'amount': '₹999', 'date': '2026-02-25', 'status': 'Failed'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(payment['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(payment['date']!, style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment['amount']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  payment['status']!,
                  style: TextStyle(
                    fontSize: 10,
                    color: payment['status'] == 'Success' ? Colors.green : (payment['status'] == 'Failed' ? Colors.red : Colors.orange),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
