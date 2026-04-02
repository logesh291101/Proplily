import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/auth_theme.dart';
import '../../theme/app_theme.dart';

class PropertyReviewDashboard extends StatefulWidget {
  const PropertyReviewDashboard({super.key});

  @override
  State<PropertyReviewDashboard> createState() => _PropertyReviewDashboardState();
}

class _PropertyReviewDashboardState extends State<PropertyReviewDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyProvider>(context, listen: false).fetchProperties();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _approveProperty(Property property) async {
    final success = await Provider.of<PropertyProvider>(context, listen: false).approveProperty(property.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property approved successfully')),
      );
    }
  }

  void _rejectProperty(Property property) async {
    final success = await Provider.of<PropertyProvider>(context, listen: false).rejectProperty(property.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property rejected successfully')),
      );
    }
  }

  void _showPropertyDetails(Property property) {
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
              if (property.propertyPhoto != null) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Property Photo'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 32),
              Row(
                children: [
                  if (property.status != PropertyStatus.approved && property.status != PropertyStatus.rejected) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectProperty(property);
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
                          _approveProperty(property);
                        },
                        style: AuthTheme.primaryButton().copyWith(
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                        ),
                        child: const Text('APPROVE'),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Center(
                        child: Text(
                          'Actions unavailable for ${property.status.displayName} properties',
                          style: const TextStyle(color: AuthTheme.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ],
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
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final allProperties = propertyProvider.properties;
    final isLoading = propertyProvider.isLoading;

    final pending = allProperties.where((p) => p.status.displayName == 'Pending').toList();
    final approved = allProperties.where((p) => p.status.displayName == 'Approved').toList();
    final rejected = allProperties.where((p) => p.status.displayName == 'Rejected').toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AuthTheme.scaffoldBg,
        appBar: AppBar(
          title: const Text('Property Review'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'PENDING'),
              Tab(text: 'APPROVED'),
              Tab(text: 'REJECTED'),
            ],
          ),
        ),
        body: isLoading && allProperties.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildPropertyGrid(pending),
                  _buildPropertyGrid(approved),
                  _buildPropertyGrid(rejected),
                ],
              ),
      ),
    );
  }

  Widget _buildPropertyGrid(List<Property> properties) {
    if (properties.isEmpty) {
      return const Center(child: Text('No properties found in this category'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
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
                    const Icon(Icons.location_on_outlined, size: 14, color: AuthTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      property.city.isNotEmpty ? property.city : 'Location',
                      style: const TextStyle(fontSize: 12, color: AuthTheme.textSecondary),
                    ),
                    const Spacer(),
                    _buildStatusChip(property.status),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPropertyDetails(property),
          ),
        );
      },
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
    Color color;
    final label = status.displayName;

    switch (status) {
      case PropertyStatus.propertyAdded:
      case PropertyStatus.pendingVerification:
        color = Colors.orange;
        break;
      case PropertyStatus.approved:
        color = Colors.green;
        break;
      case PropertyStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
