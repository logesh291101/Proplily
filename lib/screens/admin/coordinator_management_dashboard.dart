import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_model.dart';
import '../../theme/auth_theme.dart';

class CoordinatorManagementDashboard extends StatefulWidget {
  const CoordinatorManagementDashboard({super.key});

  @override
  State<CoordinatorManagementDashboard> createState() => _CoordinatorManagementDashboardState();
}

class _CoordinatorManagementDashboardState extends State<CoordinatorManagementDashboard> {
  // Mock data for coordinators
  final List<User> _coordinators = [
    User(
      id: 'coord_1',
      fullName: 'Rahul Sharma',
      email: 'rahul.s@proplilly.com',
      phoneNumber: '+91 9123443210',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      isActive: true,
    ),
    User(
      id: 'coord_2',
      fullName: 'Priya Singh',
      email: 'priya.s@proplilly.com',
      phoneNumber: '+91 9888877777',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      isActive: true,
    ),
    User(
      id: 'coord_3',
      fullName: 'Amit Kumar',
      email: 'amit.k@proplilly.com',
      phoneNumber: '+91 9777766666',
      userType: UserType.coordinator,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isActive: false, // Pending approval
    ),
  ];

  void _toggleCoordinatorStatus(int index) {
    setState(() {
      final coordinator = _coordinators[index];
      _coordinators[index] = User(
        id: coordinator.id,
        fullName: coordinator.fullName,
        email: coordinator.email,
        phoneNumber: coordinator.phoneNumber,
        userType: coordinator.userType,
        createdAt: coordinator.createdAt,
        isActive: !coordinator.isActive,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Coordinator ${_coordinators[index].isActive ? "activated" : "deactivated"}')),
    );
  }

  void _showCoordinatorDetails(User coordinator, int index) {
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
                    coordinator.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AuthTheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coordinator.fullName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        coordinator.email,
                        style: const TextStyle(color: AuthTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(coordinator.isActive),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoRow(Icons.phone_outlined, 'Phone', coordinator.phoneNumber),
            _buildInfoRow(Icons.calendar_today_outlined, 'Joined', coordinator.createdAt.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleCoordinatorStatus(index);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: coordinator.isActive ? Colors.red : Colors.green,
                      side: BorderSide(color: coordinator.isActive ? Colors.red : Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(coordinator.isActive ? 'DEACTIVATE' : 'APPROVE / ACTIVATE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/admin/assign-property', extra: coordinator);
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
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Coordinator Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _coordinators.length,
        itemBuilder: (context, index) {
          final coordinator = _coordinators[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: AuthTheme.primary.withOpacity(0.1),
                child: Text(
                  coordinator.fullName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: AuthTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                coordinator.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(coordinator.email),
              trailing: _buildStatusChip(coordinator.isActive),
              onTap: () => _showCoordinatorDetails(coordinator, index),
            ),
          );
        },
      ),
    );
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
