import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/auth_theme.dart';

class PropertyReviewDashboard extends StatefulWidget {
  const PropertyReviewDashboard({super.key});

  @override
  State<PropertyReviewDashboard> createState() => _PropertyReviewDashboardState();
}

class _PropertyReviewDashboardState extends State<PropertyReviewDashboard> {
  // Mock data for pending properties
  final List<Property> _pendingProperties = [
    Property(
      id: '1',
      propertyName: 'Green Valley Villa',
      propertyType: PropertyType.independentHouse,
      propertyAddress: '123, Sector 4, Bangalore',
      ownerName: 'John Doe',
      contactNumber: '+91 9876543210',
      latitude: 12.9716,
      longitude: 77.5946,
      ownerId: 'owner_1',
      status: PropertyStatus.pendingVerification,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      documentUrls: ['doc1.pdf', 'doc2.jpg'],
      propertyImages: ['img1.jpg'],
    ),
    Property(
      id: '2',
      propertyName: 'Skyline Apartment',
      propertyType: PropertyType.apartment,
      propertyAddress: '45, MG Road, Mumbai',
      ownerName: 'Jane Smith',
      contactNumber: '+91 9123456789',
      latitude: 19.0760,
      longitude: 72.8777,
      ownerId: 'owner_2',
      status: PropertyStatus.pendingVerification,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  void _approveProperty(int index) {
    setState(() {
      _pendingProperties.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Property approved successfully')),
    );
  }

  void _rejectProperty(int index, String reason) {
    setState(() {
      _pendingProperties.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Property rejected: $reason')),
    );
  }

  void _showRejectionDialog(int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejection Reason'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter mandatory rejection reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _rejectProperty(index, controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showPropertyDetails(Property property, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.propertyName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AuthTheme.textPrimary,
                          ),
                        ),
                        Text(
                          property.propertyType.toString().split('.').last.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AuthTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(property.status),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Property Information'),
              _buildInfoRow(Icons.location_on_outlined, 'Address', property.propertyAddress),
              _buildInfoRow(Icons.map_outlined, 'Coordinates', '${property.latitude}, ${property.longitude}'),
              const SizedBox(height: 16),
              _buildSectionTitle('Owner Details'),
              _buildInfoRow(Icons.person_outline, 'Name', property.ownerName),
              _buildInfoRow(Icons.phone_outlined, 'Phone', property.contactNumber),
              const SizedBox(height: 16),
              _buildSectionTitle('Documents & Images'),
              Text(
                'Documents: ${property.documentUrls.length}',
                style: const TextStyle(color: AuthTheme.textSecondary),
              ),
              Text(
                'Images: ${property.propertyImages.length}',
                style: const TextStyle(color: AuthTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRejectionDialog(index);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('REJECT'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _approveProperty(index);
                      },
                      style: AuthTheme.primaryButton().copyWith(
                        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                      ),
                      child: const Text('APPROVE'),
                    ),
                  ),
                ],
              ),
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
        title: const Text('Property Review'),
      ),
      body: _pendingProperties.isEmpty
          ? const Center(child: Text('No pending properties to review'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingProperties.length,
              itemBuilder: (context, index) {
                final property = _pendingProperties[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      property.propertyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(property.propertyAddress),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AuthTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              property.ownerName,
                              style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPropertyDetails(property, index),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AuthTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AuthTheme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: AuthTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PropertyStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }
}
