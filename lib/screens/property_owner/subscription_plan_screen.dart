import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/subscription_model.dart';
import '../../services/subscription_service.dart';
import '../../theme/auth_theme.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  bool _isLoading = false;

  Future<void> _selectPlan(SubscriptionPlan plan, SubscriptionPeriod period, double amount) async {
    setState(() => _isLoading = true);
    final subscription = await SubscriptionService().processSubscriptionPayment(
      plan: plan,
      period: period,
      amount: amount,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      if (subscription != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful. Subscription active!')),
        );
        context.go('/customer/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Select a Subscription Plan'),
        automaticallyImplyLeading: false, // Force them to select before continuing
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'Choose your Property Management Plan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AuthTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock continuous monitoring, emergency inspections, and professional property management for ultimate peace of mind.',
                style: TextStyle(fontSize: 14, color: AuthTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                title: 'Basic Plan',
                price: '\$49/month',
                description: 'Ideal for single property owners who need essential tracking and periodic updates.',
                features: [
                  'Standard Property Support',
                  'Email Support (48h response)',
                  '1 Emergency Inspection/yr',
                  'Basic Visit Tracking'
                ],
                onTap: () => _selectPlan(SubscriptionPlan.basic, SubscriptionPeriod.monthly, 49.0),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                title: 'Premium Plan',
                price: '\$99/month',
                description: 'Comprehensive management with priority handling, dedicated coordinator, and 24/7 support.',
                features: [
                  'Live Priority Monitoring',
                  '24/7 Phone Support',
                  'Unlimited Emergency Inspections',
                  'Dedicated Area Coordinator',
                  'Basic Legal Assistance'
                ],
                isPremium: true,
                onTap: () => _selectPlan(SubscriptionPlan.premium, SubscriptionPeriod.monthly, 99.0),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: const Text('Cancel & Logout'),
              ),
            ],
          ),
    ));
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    String? description,
    required List<String> features,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Card(
      elevation: isPremium ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPremium ? const BorderSide(color: AuthTheme.primary, width: 2) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (isPremium)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AuthTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(price, style: const TextStyle(fontSize: 32, color: AuthTheme.primary, fontWeight: FontWeight.bold)),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: AuthTheme.textSecondary, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f, style: const TextStyle(fontSize: 14, height: 1.3))),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Select Plan & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
