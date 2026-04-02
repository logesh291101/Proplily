import 'package:flutter/material.dart';
import '../../models/service_request_model.dart'; // From models
import '../../services/service_request_service.dart'; // The service
import '../../theme/auth_theme.dart';

// Removed Issue, IssueSeverity, IssueStatus since ServiceRequest covers it

class EmergencyDashboard extends StatefulWidget {
  const EmergencyDashboard({super.key});

  @override
  State<EmergencyDashboard> createState() => _EmergencyDashboardState();
}

class _EmergencyDashboardState extends State<EmergencyDashboard> {
  List<ServiceRequest> _issues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  Future<void> _loadIssues() async {
    setState(() => _isLoading = true);
    final issues = await ServiceRequestService().getPendingEmergencyRequests();
    if (mounted) {
      setState(() {
        _issues = issues;
        _isLoading = false;
      });
    }
  }

  void _updateIssueStatus(int index, ServiceRequestStatus newStatus) async {
    final issueId = _issues[index].id;
    final success = await ServiceRequestService().updateRequestStatus(issueId, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue status updated to ${newStatus.toString().split('.').last}')),
      );
      _loadIssues();
    }
  }

  void _showIssueDetails(ServiceRequest issue, int index) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Emergency Request',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSeverityChip(),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.business_outlined, 'Property ID', issue.propertyName ?? 'Unknown'),
            _buildInfoRow(Icons.access_time, 'Reported At', issue.createdAt.toString().split('.')[0]),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(issue.description ?? 'No description', style: const TextStyle(color: AuthTheme.textSecondary)),
            const SizedBox(height: 32),
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusButton(index, ServiceRequestStatus.pendingVerification, 'PENDING', Colors.blue),
                const SizedBox(width: 8),
                _buildStatusButton(index, ServiceRequestStatus.inProgress, 'IN PROGRESS', Colors.orange),
                const SizedBox(width: 8),
                _buildStatusButton(index, ServiceRequestStatus.completed, 'RESOLVE', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(int index, ServiceRequestStatus status, String label, Color color) {
    bool isCurrent = _issues[index].status == status;
    return Expanded(
      child: ElevatedButton(
        onPressed: isCurrent ? null : () {
          Navigator.pop(context);
          _updateIssueStatus(index, status);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrent ? color.withOpacity(0.1) : color,
          foregroundColor: isCurrent ? color : Colors.white,
          elevation: isCurrent ? 0 : 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Emergency & Issues')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _issues.isEmpty
          ? const Center(child: Text('No active issues reported'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _issues.length,
              itemBuilder: (context, index) {
                final issue = _issues[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    ),
                    title: const Text('Emergency Request', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Property: ${issue.propertyName ?? 'Unknown'}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),
                        _buildStatusChip(issue.status),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showIssueDetails(issue, index),
                  ),
                );
              },
            ),
    ));
  }

  Widget _buildSeverityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'CRITICAL',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  Widget _buildStatusChip(ServiceRequestStatus status) {
    Color color;
    switch (status) {
      case ServiceRequestStatus.pendingVerification: color = Colors.blue; break;
      case ServiceRequestStatus.inProgress: color = Colors.orange; break;
      case ServiceRequestStatus.completed: color = Colors.green; break;
      default: color = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

// Removed _getSeverityColor

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AuthTheme.primary.withOpacity(0.7)),
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
