import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final String propertyId;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    final propertyService = PropertyService();

    return SafeArea(child: Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Property?>(
        future: propertyService.getPropertyById(propertyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(
              child: Text('Failed to load property details'),
            );
          }

          final property = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.propertyName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(property.status),
                const SizedBox(height: 24),
                _buildDetailRow('Property Type', _getPropertyTypeLabel(property.propertyType)),
                _buildDetailRow('Address', property.propertyAddress),
                _buildDetailRow('Location', '${property.latitude}, ${property.longitude}'),
                if (property.city.isNotEmpty) _buildDetailRow('City', property.city),
                const SizedBox(height: 24),
                if (property.propertyPhoto != null) ...[
                  const Text(
                    'Property Photo',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      property.propertyPhoto!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(PropertyStatus status) {
    Color color;
    String label;

    switch (status) {
      case PropertyStatus.propertyAdded:
        color = Colors.blue.shade200;
        label = 'Pending Review';
        break;
      case PropertyStatus.pendingVerification:
        color = Colors.deepPurple.shade200;
        label = 'Pending Verification';
        break;
      case PropertyStatus.approved:
        color = Colors.deepPurple;
        label = 'Approved';
        break;
      case PropertyStatus.rejected:
        color = Colors.deepPurple.shade700;
        label = 'Rejected';
        break;
      case PropertyStatus.cancelled:
        color = Colors.grey.shade400;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    final textColor = color == Colors.deepPurple.shade200 ? Colors.deepPurple.shade900 : Colors.white;
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
      backgroundColor: color,
    );
  }

  String _getPropertyTypeLabel(PropertyType type) {
    switch (type) {
      case PropertyType.land:
        return 'Land';
      case PropertyType.independentHouse:
        return 'Independent House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.flat:
        return 'Flat';
    }
  }
}
