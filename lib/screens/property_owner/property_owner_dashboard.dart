import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import 'add_property_screen.dart';
import 'request_documentation_screen.dart';
import 'request_brokering_screen.dart';
import 'property_details_screen.dart';

class PropertyOwnerDashboard extends StatefulWidget {
  const PropertyOwnerDashboard({super.key});

  @override
  State<PropertyOwnerDashboard> createState() => _PropertyOwnerDashboardState();
}

class _PropertyOwnerDashboardState extends State<PropertyOwnerDashboard> {
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    final properties = await _propertyService.getProperties();
    setState(() {
      _properties = properties;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProperties,
              child: Column(
                children: [
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/property-owner/add-property'),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Property'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/property-owner/request-documentation'),
                                icon: const Icon(Icons.description),
                                label: const Text('Request Documentation'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/property-owner/request-brokering'),
                                icon: const Icon(Icons.handshake),
                                label: const Text('Request Brokering'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Properties List
                  Expanded(
                    child: _properties.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, size: 64, color: Colors.deepPurple.shade200),
                                const SizedBox(height: 16),
                                const Text(
                                  'No properties yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add your first property to get started',
                                  style: TextStyle(color: Colors.deepPurple),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _properties.length,
                            itemBuilder: (context, index) {
                              final property = _properties[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    _getPropertyTypeIcon(property.propertyType),
                                    size: 40,
                                  ),
                                  title: Text(property.propertyName),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(property.propertyAddress),
                                      const SizedBox(height: 4),
                                      _buildStatusChip(property.status),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push(
                                    '/property-owner/property/${property.id}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/property-owner/add-property'),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getPropertyTypeIcon(PropertyType type) {
    switch (type) {
      case PropertyType.land:
        return Icons.landscape;
      case PropertyType.independentHouse:
        return Icons.home;
      case PropertyType.apartment:
        return Icons.apartment;
      case PropertyType.flat:
        return Icons.business;
    }
  }

  Widget _buildStatusChip(PropertyStatus status) {
    Color color;
    String label;

    switch (status) {
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
    }

    final textColor = color == Colors.deepPurple.shade200 ? Colors.deepPurple.shade900 : Colors.white;
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
