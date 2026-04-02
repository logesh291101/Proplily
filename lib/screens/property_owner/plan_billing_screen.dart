import 'package:flutter/material.dart';
import '../../theme/auth_theme.dart';
import '../../services/subscription_service.dart';

class PlanBillingScreen extends StatelessWidget {
  const PlanBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app we would fetch user's strict subscription here. 
    final hasSubscription = SubscriptionService().hasActiveSubscription;

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Plan & Billing'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Plan', style: TextStyle(color: AuthTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      hasSubscription ? 'Premium Plan' : 'Free / No Plan',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AuthTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    if (hasSubscription)
                      const Text('Status: Active\nNext Billing Date: Oct 1, 2026', style: TextStyle(height: 1.5))
                    else
                      const Text('You do not have an active subscription.'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: AuthTheme.primaryButton(),
                      child: Text(hasSubscription ? 'Manage Subscription' : 'Upgrade Plan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Billing History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (hasSubscription) ...[
              _buildInvoiceTile('INV-2026-001', 'Sep 1, 2026', '\$99.00', 'Paid'),
              _buildInvoiceTile('INV-2026-000', 'Aug 1, 2026', '\$99.00', 'Paid'),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No billing history available.', style: TextStyle(color: AuthTheme.textSecondary)),
                ),
              )
            ]
          ],
        ),
      ),
    ));
  }

  Widget _buildInvoiceTile(String invoice, String date, String amount, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AuthTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.receipt_long, color: AuthTheme.primary),
        ),
        title: Text(invoice, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
