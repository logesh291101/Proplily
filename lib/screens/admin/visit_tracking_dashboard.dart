import 'package:flutter/material.dart';
import '../../models/visit_model.dart';
import '../../theme/auth_theme.dart';

class VisitTrackingDashboard extends StatefulWidget {
  const VisitTrackingDashboard({super.key});

  @override
  State<VisitTrackingDashboard> createState() => _VisitTrackingDashboardState();
}

class _VisitTrackingDashboardState extends State<VisitTrackingDashboard> {
  // Mock data for visits
  final List<Visit> _visits = [
    Visit(
      id: 'v1',
      propertyId: 'prop_1',
      coordinatorId: 'coord_1',
      scheduledDate: DateTime.now().subtract(const Duration(hours: 2)),
      startTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      status: VisitStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      startLatitude: 12.9716,
      startLongitude: 77.5946,
      endLatitude: 12.9718,
      endLongitude: 77.5948,
      geoTaggedImages: ['visit_img1.jpg', 'visit_img2.jpg'],
      visitRemarks: 'Everything looks good. No issues found.',
    ),
    Visit(
      id: 'v2',
      propertyId: 'prop_2',
      coordinatorId: 'coord_2',
      scheduledDate: DateTime.now().add(const Duration(hours: 4)),
      status: VisitStatus.notStarted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Visit(
      id: 'v3',
      propertyId: 'prop_3',
      coordinatorId: 'coord_1',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      status: VisitStatus.missed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  VisitStatus? _filterStatus;

  List<Visit> get _filteredVisits {
    if (_filterStatus == null) return _visits;
    return _visits.where((v) => v.status == _filterStatus).toList();
  }

  void _showVisitDetails(Visit visit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
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
                  const Text(
                    'Visit Details',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusChip(visit.status),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.business_outlined, 'Property ID', visit.propertyId),
              _buildInfoRow(Icons.person_outline, 'Helper ID', visit.coordinatorId),
              _buildInfoRow(Icons.calendar_today_outlined, 'Scheduled', visit.scheduledDate?.toString().split('.')[0] ?? 'N/A'),
              if (visit.startTime != null)
                _buildInfoRow(Icons.access_time, 'Execution Time', '${visit.startTime?.toString().split(' ')[1].substring(0, 5)} - ${visit.endTime?.toString().split(' ')[1].substring(0, 5)}'),
              if (visit.startLatitude != null)
                _buildInfoRow(Icons.location_on_outlined, 'Location', '${visit.startLatitude}, ${visit.startLongitude}'),
              if (visit.visitRemarks != null)
                _buildInfoRow(Icons.notes, 'Remarks', visit.visitRemarks!),
              if (visit.geoTaggedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Geo-tagged Images', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visit.geoTaggedImages.length,
                    itemBuilder: (context, index) => Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.image_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Visit Monitoring'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildFilterChip(null, 'All'),
                const SizedBox(width: 8),
                _buildFilterChip(VisitStatus.notStarted, 'Not Started'),
                const SizedBox(width: 8),
                _buildFilterChip(VisitStatus.started, 'Started'),
                const SizedBox(width: 8),
                _buildFilterChip(VisitStatus.completed, 'Completed'),
                const SizedBox(width: 8),
                _buildFilterChip(VisitStatus.missed, 'Missed'),
              ],
            ),
          ),
        ),
      ),
      body: _filteredVisits.isEmpty
          ? const Center(child: Text('No visits found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredVisits.length,
              itemBuilder: (context, index) {
                final visit = _filteredVisits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(visit.status).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getStatusIcon(visit.status), color: _getStatusColor(visit.status)),
                    ),
                    title: Text(
                      'Property ID: ${visit.propertyId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Coordinator: ${visit.coordinatorId}', style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          visit.scheduledDate?.toString().split('.')[0] ?? 'N/A',
                          style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary),
                        ),
                      ],
                    ),
                    trailing: _buildStatusChip(visit.status),
                    onTap: () => _showVisitDetails(visit),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip(VisitStatus? status, String label) {
    bool isSelected = _filterStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      selectedColor: AuthTheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AuthTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatusChip(VisitStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.notStarted:
        return Colors.blue;
      case VisitStatus.started:
        return Colors.orange;
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.missed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.notStarted:
        return Icons.calendar_today_outlined;
      case VisitStatus.started:
        return Icons.play_arrow_outlined;
      case VisitStatus.completed:
        return Icons.check_circle_outline;
      case VisitStatus.missed:
        return Icons.error_outline;
    }
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
