import 'package:flutter/material.dart';
import '../../theme/auth_theme.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Support Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSupportOption(
            context: context,
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Chat with our support team instantly.',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Live Chat feature coming soon.')));
            },
          ),
          _buildSupportOption(
            context: context,
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Send us an email and we will reply within 24 hours.',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support email: support@proplilly.com')));
            },
          ),
          _buildSupportOption(
            context: context,
            icon: Icons.confirmation_number_outlined,
            title: 'Raise a Ticket',
            subtitle: 'File a detailed report for technical issues.',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ticket system coming soon.')));
            },
          ),
          const SizedBox(height: 32),
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFAQItem('How do I request an emergency inspection?', 'You can click on the Request Emergency Inspection button on your dashboard. This instantly notifies the admin and your assigned coordinator.'),
          _buildFAQItem('Can I upgrade my subscription plan?', 'Yes, navigate to Plan & Billing from the Drawer menu to upgrade your plan anytime.'),
          _buildFAQItem('How are properties verified?', 'Once you add a property, our admin team reviews the details and legal documents before approval. The status on your dashboard will change from Waiting for Verification to Approved.'),
        ],
      ),
    ));
  }

  Widget _buildSupportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AuthTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AuthTheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: const TextStyle(color: AuthTheme.textSecondary, height: 1.5)),
        ),
      ],
    );
  }
}
