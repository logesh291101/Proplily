import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/auth_theme.dart';
import '../../theme/app_theme.dart';
import '../../services/property_service.dart';
import '../../services/service_request_service.dart';
import '../../models/property_model.dart';
import '../../models/service_request_model.dart';
import '../../widgets/coordinator_drawer.dart';

class CoordinatorDashboard extends StatefulWidget {
  const CoordinatorDashboard({super.key});

  @override
  State<CoordinatorDashboard> createState() => _CoordinatorDashboardState();
}

class _CoordinatorDashboardState extends State<CoordinatorDashboard> {
  bool _isLoading = true;
  int _currentIndex = 0;

  List<Property> _assignedProperties = [];
  List<ServiceRequest> _assignedEmergencies = [];
  List<Property> _myProperties = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      final properties = await PropertyService().getAssignedProperties(user.id);
      final emergencies = await ServiceRequestService().getAssignedRequests(user.id);
      final myProps = await PropertyService().getProperties();
      
      if (mounted) {
        setState(() {
          _assignedProperties = properties;
          _assignedEmergencies = emergencies;
          _myProperties = myProps;
          _isLoading = false;
        });
      }
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
    String label;

    switch (status) {
      case PropertyStatus.propertyAdded:
        color = Colors.blue.shade100;
        label = 'Property Added';
        break;
      case PropertyStatus.pendingVerification:
        color = Colors.orange.shade100;
        label = 'Waiting for Verification';
        break;
      case PropertyStatus.approved:
        color = Colors.green.shade100;
        label = 'Approved';
        break;
      case PropertyStatus.rejected:
        color = Colors.red.shade100;
        label = 'Rejected';
        break;
      case PropertyStatus.cancelled:
        color = Colors.grey.shade300;
        label = 'Cancelled';
        break;
    }

    final textColor = (status == PropertyStatus.approved) ? Colors.green.shade900 : Colors.black87;
    return Chip(
      label: Text(
        label,
        style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildAssignedTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_assignedEmergencies.isNotEmpty) ...[
            const Text('Emergency Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 8),
            ..._assignedEmergencies.map((req) => Card(
              color: Colors.red.shade50,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.red),
                title: Text(req.propertyName ?? 'Unknown Property', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Reported: ${req.createdAt.toString().split('.')[0]}'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  onPressed: () {
                    ServiceRequestService().updateRequestStatus(req.id, ServiceRequestStatus.completed);
                    _loadAllData();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency resolved!')));
                  },
                  child: const Text('RESOLVE'),
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
          const Text('Assigned Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_assignedProperties.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.assignment_outlined, size: 64, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    const Text('No properties assigned yet', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            ..._assignedProperties.map((prop) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.home, color: AuthTheme.primary),
                title: Text(prop.propertyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(prop.propertyAddress),
                trailing: ElevatedButton.icon(
                   icon: const Icon(Icons.assignment, size: 16),
                   label: const Text('Submit Report'),
                   onPressed: () {
                     context.push('/coordinator/submit-report', extra: prop);
                   },
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildMyPropertiesTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('My Properties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_myProperties.isEmpty)
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
            ..._myProperties.map((property) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      ],
                    ),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const CoordinatorDrawer(),
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'Assigned Properties' : 'My Properties'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _currentIndex == 0 ? _buildAssignedTab() : _buildMyPropertiesTab(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assigned'),
            BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'My Properties'),
          ],
          selectedItemColor: AppColors.primary,
        ),
        floatingActionButton: _currentIndex == 1
            ? FloatingActionButton(
                onPressed: () => context.push('/coordinator/add-property'),
                shape: const CircleBorder(),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
