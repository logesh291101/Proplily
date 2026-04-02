import 'package:flutter/material.dart';
import '../../models/service_request_model.dart';
import '../../theme/auth_theme.dart';

class ServiceRequestManager extends StatefulWidget {
  const ServiceRequestManager({super.key});

  @override
  State<ServiceRequestManager> createState() => _ServiceRequestManagerState();
}

class _ServiceRequestManagerState extends State<ServiceRequestManager> {
  // Mock data for service requests
  final List<ServiceRequest> _requests = [
    ServiceRequest(
      id: 'sr1',
      requestType: ServiceRequestType.documentation,
      propertyName: 'Green Valley Villa',
      propertyAddress: '123, Sector 4, Bangalore',
      ownerName: 'John Doe',
      contactNumber: '+91 9876543210',
      description: 'Need assistance with property registration documents.',
      status: ServiceRequestStatus.requested,
      ownerId: 'owner_1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ServiceRequest(
      id: 'sr2',
      requestType: ServiceRequestType.brokering,
      propertyName: 'Skyline Apartment',
      propertyAddress: '45, MG Road, Mumbai',
      ownerName: 'Jane Smith',
      contactNumber: '+91 9123456789',
      description: 'Looking to rent out the unit. Need brokerage support.',
      status: ServiceRequestStatus.assigned,
      assignedToId: 'agent_x',
      ownerId: 'owner_2',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
  ];

  void _updateRequestStatus(int index, ServiceRequestStatus newStatus) {
    setState(() {
      final request = _requests[index];
      _requests[index] = ServiceRequest(
        id: request.id,
        requestType: request.requestType,
        propertyName: request.propertyName,
        propertyAddress: request.propertyAddress,
        ownerName: request.ownerName,
        contactNumber: request.contactNumber,
        description: request.description,
        status: newStatus,
        assignedToId: request.assignedToId,
        ownerId: request.ownerId,
        createdAt: request.createdAt,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request status updated to ${newStatus.toString().split('.').last}')),
    );
  }

  void _showRequestDetails(ServiceRequest request, int index) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requestType.toString().split('.').last.toUpperCase(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AuthTheme.primary),
                    ),
                    const Text(
                      'Service Request',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                _buildStatusChip(request.status),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.business_outlined, 'Property', request.propertyName ?? 'N/A'),
            _buildInfoRow(Icons.location_on_outlined, 'Address', request.propertyAddress ?? 'N/A'),
            _buildInfoRow(Icons.person_outline, 'Owner', request.ownerName ?? 'N/A'),
            _buildInfoRow(Icons.message_outlined, 'Description', request.description ?? 'No description provided'),
            const SizedBox(height: 32),
            const Text('Manage Request', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateRequestStatus(index, ServiceRequestStatus.rejected);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('REJECT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateRequestStatus(index, ServiceRequestStatus.assigned);
                    },
                    style: AuthTheme.primaryButton(),
                    child: const Text('ASSIGN'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateRequestStatus(index, ServiceRequestStatus.completed);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('COMPLETE'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(title: const Text('Service Requests')),
      body: _requests.isEmpty
          ? const Center(child: Text('No service requests found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final request = _requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AuthTheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        request.requestType == ServiceRequestType.documentation ? Icons.description_outlined : Icons.handshake_outlined,
                        color: AuthTheme.primary,
                      ),
                    ),
                    title: Text(request.propertyName ?? 'Unknown Property', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(request.requestType.toString().split('.').last.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AuthTheme.primary)),
                        const SizedBox(height: 8),
                        _buildStatusChip(request.status),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showRequestDetails(request, index),
                  ),
                );
              },
            ),
    ));
  }

  Widget _buildStatusChip(ServiceRequestStatus status) {
    Color color;
    switch (status) {
      case ServiceRequestStatus.requested: color = Colors.blue; break;
      case ServiceRequestStatus.assigned: color = Colors.orange; break;
      case ServiceRequestStatus.completed: color = Colors.green; break;
      case ServiceRequestStatus.rejected: color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AuthTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
