import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../theme/auth_theme.dart';

class HelperManagementDashboard extends StatefulWidget {
  const HelperManagementDashboard({super.key});

  @override
  State<HelperManagementDashboard> createState() => _HelperManagementDashboardState();
}

class _HelperManagementDashboardState extends State<HelperManagementDashboard> {
  // Mock data for helpers
  final List<User> _helpers = [
    User(
      id: 'helper_1',
      fullName: 'Rahul Sharma',
      email: 'rahul.s@proplilly.com',
      phoneNumber: '+91 9123443210',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isActive: true,
    ),
    User(
      id: 'helper_2',
      fullName: 'Priya Singh',
      email: 'priya.s@proplilly.com',
      phoneNumber: '+91 9888877777',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
    ),
    User(
      id: 'helper_3',
      fullName: 'Amit Kumar',
      email: 'amit.k@proplilly.com',
      phoneNumber: '+91 9777766666',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isActive: false, // Pending approval
    ),
  ];

  void _toggleHelperStatus(int index) {
    setState(() {
      final helper = _helpers[index];
      _helpers[index] = User(
        id: helper.id,
        fullName: helper.fullName,
        email: helper.email,
        phoneNumber: helper.phoneNumber,
        userType: helper.userType,
        createdAt: helper.createdAt,
        isActive: !helper.isActive,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Helper ${_helpers[index].isActive ? "activated" : "deactivated"}')),
    );
  }

  void _showHelperDetails(User helper, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AuthTheme.primary.withOpacity(0.1),
                  child: Text(
                    helper.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AuthTheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helper.fullName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        helper.email,
                        style: const TextStyle(color: AuthTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(helper.isActive),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow(Icons.phone_outlined, 'Phone', helper.phoneNumber),
            _buildInfoRow(Icons.calendar_today_outlined, 'Joined', helper.createdAt.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleHelperStatus(index);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: helper.isActive ? Colors.red : Colors.green,
                      side: BorderSide(color: helper.isActive ? Colors.red : Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(helper.isActive ? 'DEACTIVATE' : 'APPROVE / ACTIVATE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/admin/assign-property', extra: helper);
                    },
                    style: AuthTheme.primaryButton(),
                    child: const Text('ASSIGN PROPERTIES'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Helper Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _helpers.length,
        itemBuilder: (context, index) {
          final helper = _helpers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AuthTheme.primary.withOpacity(0.1),
                child: Text(
                  helper.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AuthTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                helper.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(helper.email),
              trailing: _buildStatusChip(helper.isActive),
              onTap: () => _showHelperDetails(helper, index),
            ),
          );
        },
      ),
    ));
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AuthTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
