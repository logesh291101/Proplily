import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'dart:developer';
import '../../models/property_model.dart';
import '../../providers/property_provider.dart';
import '../../services/property_service.dart';
import '../../widgets/osm_location_picker.dart';
import '../../widgets/file_upload_widget.dart';
import '../../theme/auth_theme.dart';

class AdminAddPropertyScreen extends StatefulWidget {
  const AdminAddPropertyScreen({super.key});

  @override
  State<AdminAddPropertyScreen> createState() => _AdminAddPropertyScreenState();
}

class _AdminAddPropertyScreenState extends State<AdminAddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _cityController = TextEditingController();

  PropertyType _selectedPropertyType = PropertyType.land;
  double? _latitude;
  double? _longitude;
  String? _propertyPhotoPath;
  bool _isLoading = false;

  final PropertyService _propertyService = PropertyService();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyAddressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          String address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          
          _propertyAddressController.text = address;
          _cityController.text = place.locality ?? place.subAdministrativeArea ?? '';
        });
      }
    } catch (e) {
      log("Geocoding error: $e");
    }
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

    if (_propertyPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a property photo'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await Provider.of<PropertyProvider>(context, listen: false).addProperty(
      propertyName: _propertyNameController.text.trim(),
      propertyType: _selectedPropertyType,
      propertyAddress: _propertyAddressController.text.trim(),
      city: _cityController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      propertyPhoto: File(_propertyPhotoPath!),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property added successfully!'),
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
    return SafeArea(child: Scaffold(
      backgroundColor: AuthTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Add Property (Admin)'),
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
                        hintText: 'Full Property Address *',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (value) => 
                        value?.trim().isEmpty ?? true ? 'Property address is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: AuthTheme.inputDecoration(
                        hintText: 'City *',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                      validator: (value) => 
                        value?.trim().isEmpty ?? true ? 'City is required' : null,
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
                            _reverseGeocode(lat, lng);
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
                    _buildSectionHeader('Property Photo', Icons.upload_file_outlined),
                    const Text(
                      'Upload a photo of the property',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FileUploadWidget(
                      allowedExtensions: const ['jpg', 'jpeg', 'png'],
                      maxFiles: 1,
                      onFilesSelected: (files) => 
                        setState(() => _propertyPhotoPath = files.isNotEmpty ? files.first : null),
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
                    : const Text('Add Property'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    ));
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
