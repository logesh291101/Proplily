import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../widgets/osm_location_picker.dart';
import '../../widgets/file_upload_widget.dart';
import '../../theme/auth_theme.dart';
import '../../theme/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  PropertyType _selectedPropertyType = PropertyType.land;
  double? _latitude;
  double? _longitude;
  List<String> _documentUrls = [];
  List<String> _propertyImages = [];
  bool _isLoading = false;

  final PropertyService _propertyService = PropertyService();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyAddressController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final property = await _propertyService.addProperty(
      propertyName: _propertyNameController.text.trim(),
      propertyType: _selectedPropertyType,
      propertyAddress: _propertyAddressController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      documentUrls: _documentUrls,
      propertyImages: _propertyImages,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (property != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property submitted for review successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add property. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AuthTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AuthTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AuthTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Add Property'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTheme.authCard(
                child: Column(
                  children: [
                    _buildSectionHeader('Basic Details', Icons.home_work_outlined),
                    DropdownButtonFormField<PropertyType>(
                      value: _selectedPropertyType,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'Property Type',
                        prefixIcon: Icons.category_outlined,
                      ),
                      items: PropertyType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getPropertyTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPropertyType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _propertyNameController,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'Property Name (e.g. My Dream House)',
                        prefixIcon: Icons.drive_file_rename_outline,
                      ),
                      validator: (value) => 
                        value?.isEmpty ?? true ? 'Enter property name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _propertyAddressController,
                      maxLines: 2,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'Full Property Address',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (value) => 
                        value?.isEmpty ?? true ? 'Enter property address' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthTheme.authCard(
                child: Column(
                  children: [
                    _buildSectionHeader('Owner Information', Icons.person_outline),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'Owner Full Name',
                        prefixIcon: Icons.account_circle_outlined,
                      ),
                      validator: (value) => 
                        value?.isEmpty ?? true ? 'Enter owner name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'Contact Number',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      validator: (value) => 
                        value?.isEmpty ?? true ? 'Enter contact number' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthTheme.authCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildSectionHeader('Pin Location on Map', Icons.map_outlined),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: SizedBox(
                        height: 300,
                        child: OSMLocationPicker(
                          initialLatitude: _latitude,
                          initialLongitude: _longitude,
                          onLocationSelected: (lat, lng) {
                            setState(() {
                              _latitude = lat;
                              _longitude = lng;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AuthTheme.authCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Media & Documents', Icons.upload_file_outlined),
                    const Text(
                      'Property Images',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FileUploadWidget(
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      maxFiles: 5,
                      onFilesSelected: (files) => 
                        setState(() => _propertyImages = files),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ownership Documents (PDF/Images)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FileUploadWidget(
                      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                      maxFiles: 3,
                      onFilesSelected: (files) => 
                        setState(() => _documentUrls = files),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: AuthTheme.primaryButton(),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Property for Review'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getPropertyTypeLabel(PropertyType type) {
    switch (type) {
      case PropertyType.land: return 'Land';
      case PropertyType.independentHouse: return 'Independent House';
      case PropertyType.apartment: return 'Apartment';
      case PropertyType.flat: return 'Flat';
    }
  }
}
