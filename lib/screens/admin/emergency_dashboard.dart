import 'package:flutter/material.dart';
import '../../theme/auth_theme.dart';

enum IssueSeverity { low, medium, high, critical }
enum IssueStatus { open, inProgress, resolved }

class Issue {
  final String id;
  final String title;
  final String descripton;
  final String propertyId;
  final IssueSeverity severity;
  final IssueStatus status;
  final DateTime timestamp;

  Issue({
    required this.id,
    required this.title,
    required this.descripton,
    required this.propertyId,
    required this.severity,
    required this.status,
    required this.timestamp,
  });
}

class EmergencyDashboard extends StatefulWidget {
  const EmergencyDashboard({super.key});

  @override
  State<EmergencyDashboard> createState() => _EmergencyDashboardState();
}

class _EmergencyDashboardState extends State<EmergencyDashboard> {
  // Mock data for issues
  final List<Issue> _issues = [
    Issue(
      id: 'i1',
      title: 'Emergency Service Request',
      descripton: 'Property owner requested immediate assistance due to a water leak.',
      propertyId: 'prop_1',
      severity: IssueSeverity.critical,
      status: IssueStatus.open,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    Issue(
      id: 'i2',
      title: 'Missed Visit Alert',
      descripton: 'Scheduled visit for today was missed by coordinator_1.',
      propertyId: 'prop_2',
      severity: IssueSeverity.high,
      status: IssueStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Issue(
      id: 'i3',
      title: 'Suspicious Activity Reported',
      descripton: 'Coordinator reported unknown individuals loitering near the property.',
      propertyId: 'prop_3',
      severity: IssueSeverity.medium,
      status: IssueStatus.resolved,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _updateIssueStatus(int index, IssueStatus newStatus) {
    setState(() {
      final issue = _issues[index];
      _issues[index] = Issue(
        id: issue.id,
        title: issue.title,
        descripton: issue.descripton,
        propertyId: issue.propertyId,
        severity: issue.severity,
        status: newStatus,
        timestamp: issue.timestamp,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue status updated to ${newStatus.toString().split('.').last}')),
    );
  }

  void _showIssueDetails(Issue issue, int index) {
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
                    issue.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSeverityChip(issue.severity),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.business_outlined, 'Property ID', issue.propertyId),
            _buildInfoRow(Icons.access_time, 'Reported At', issue.timestamp.toString().split('.')[0]),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(issue.descripton, style: const TextStyle(color: AuthTheme.textSecondary)),
            const SizedBox(height: 32),
            const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusButton(index, IssueStatus.open, 'OPEN', Colors.blue),
                const SizedBox(width: 8),
                _buildStatusButton(index, IssueStatus.inProgress, 'IN PROGRESS', Colors.orange),
                const SizedBox(width: 8),
                _buildStatusButton(index, IssueStatus.resolved, 'RESOLVE', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(int index, IssueStatus status, String label, Color color) {
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
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Emergency & Issues')),
      body: _issues.isEmpty
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
                        color: _getSeverityColor(issue.severity).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: _getSeverityColor(issue.severity)),
                    ),
                    title: Text(issue.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Property: ${issue.propertyId}', style: const TextStyle(fontSize: 12)),
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
    );
  }

  Widget _buildSeverityChip(IssueSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.toString().split('.').last.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getSeverityColor(severity)),
      ),
    );
  }

  Widget _buildStatusChip(IssueStatus status) {
    Color color;
    switch (status) {
      case IssueStatus.open: color = Colors.blue; break;
      case IssueStatus.inProgress: color = Colors.orange; break;
      case IssueStatus.resolved: color = Colors.green; break;
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

  Color _getSeverityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.low: return Colors.blue;
      case IssueSeverity.medium: return Colors.yellow.shade800;
      case IssueSeverity.high: return Colors.orange;
      case IssueSeverity.critical: return Colors.red;
    }
  }

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
