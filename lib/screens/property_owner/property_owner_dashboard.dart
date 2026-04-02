import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../services/property_service.dart';
import '../../services/subscription_service.dart';
import '../../services/service_request_service.dart';
import '../../widgets/property_owner_drawer.dart';
import '../../theme/app_theme.dart';

class PropertyOwnerDashboard extends StatefulWidget {
  const PropertyOwnerDashboard({super.key});

  @override
  State<PropertyOwnerDashboard> createState() => _PropertyOwnerDashboardState();
}

class _PropertyOwnerDashboardState extends State<PropertyOwnerDashboard> {
  final ServiceRequestService _requestService = ServiceRequestService();
  
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    // Check Subscription
    if (!SubscriptionService().hasActiveSubscription) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/property-owner/subscription');
        });
      }
      return;
    }

    await Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
  }

  void _deleteProperty(Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete ${property.propertyName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await Provider.of<PropertyProvider>(context, listen: false).deleteProperty(property.id);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property deleted.')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete property.'), backgroundColor: Colors.redAccent));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _requestEmergencyInspection(Property selectedProperty) async {
    // Create an emergency request
    await _requestService.createEmergencyRequest(selectedProperty);
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Emergency Inspection Requested'),
          content: const Text('Your request has been sent to the Admin. The status is currently Accepted & Assigned.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
          ],
        )
      );
    }
  }

  IconData _getPropertyTypeIcon(PropertyType type) {
    switch (type) {
      case PropertyType.land: return Icons.landscape;
      case PropertyType.independentHouse: return Icons.home;
      case PropertyType.apartment: return Icons.apartment;
      case PropertyType.flat: return Icons.business;
    }
  }

  Widget _buildStatusChip(PropertyStatus status) {
    Color color;
    final label = status.displayName;

    switch (status) {
      case PropertyStatus.propertyAdded:
      case PropertyStatus.pendingVerification:
        color = Colors.orange.shade100;
        break;
      case PropertyStatus.approved:
        color = Colors.green.shade100;
        break;
      case PropertyStatus.rejected:
        color = Colors.red.shade100;
        break;
      case PropertyStatus.cancelled:
        color = Colors.grey.shade300;
        break;
    }

    final textColor = (status == PropertyStatus.approved) 
        ? Colors.green.shade900 
        : (status == PropertyStatus.rejected) 
            ? Colors.red.shade900 
            : (status == PropertyStatus.propertyAdded || status == PropertyStatus.pendingVerification)
                ? Colors.orange.shade900
                : Colors.black87;

    return Chip(
      label: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildMyPropertiesTab(List<Property> properties) {
    return RefreshIndicator(
      onRefresh: _loadProperties,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('My Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (properties.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.home_work_outlined, size: 64, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('No properties added yet', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            ...properties.map((property) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => context.push('/property-owner/property/${property.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.propertyPhoto != null)
                      Image.network(
                        property.propertyPhoto!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 140,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                        ),
                      )
                    else
                      Container(
                        height: 140,
                        color: AppColors.primary.withOpacity(0.1),
                        child: Center(child: Icon(_getPropertyTypeIcon(property.propertyType), size: 64, color: AppColors.primary)),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(property.propertyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(property.propertyAddress, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 8),
                                _buildStatusChip(property.status),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'emergency') {
                                _requestEmergencyInspection(property);
                              } else if (value == 'edit') {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit property tapped.')));
                              } else if (value == 'delete') {
                                _deleteProperty(property);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'emergency', child: Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Emergency Inspection', style: TextStyle(color: Colors.orange))])),
                              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // Mock inspection history data showcasing images, timestamp, and details
    final history = [
      {
        'image': null,
        'propName': 'Villa Arbour',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'details': 'Routine monthly inspection completed. No issues found. Exterior and interior checked.',
        'coordinator': 'Ramesh Kumar'
      },
      {
        'image': null,
        'propName': 'Skyline Apartment',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'details': 'Emergency inspection due to reported leak. Plumber assigned and leak fixed. Awaiting final payment.',
        'coordinator': 'Suresh Menon'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final date = item['date'] as DateTime;
        final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_alt, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['propName'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Inspected by: ${item['coordinator']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  item['details'] as String,
                  style: const TextStyle(height: 1.4, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('View Full Report'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final properties = propertyProvider.properties;
    final isLoading = propertyProvider.isLoading;

    return SafeArea(
      child: Scaffold(
        drawer: const PropertyOwnerDrawer(),
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'My Dashboard' : 'Inspection History'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
          ],
        ),
        body: isLoading && properties.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _currentIndex == 0 ? _buildMyPropertiesTab(properties) : _buildHistoryTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          ],
          selectedItemColor: AppColors.primary,
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () => context.push('/property-owner/add-property'),
                shape: const CircleBorder(),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
