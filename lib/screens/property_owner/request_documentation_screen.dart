import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/property_model.dart';
import '../../models/service_request_model.dart';
import '../../widgets/map_location_picker.dart';
import '../../widgets/file_upload_widget.dart';

class RequestDocumentationScreen extends StatefulWidget {
  const RequestDocumentationScreen({super.key});

  @override
  State<RequestDocumentationScreen> createState() => _RequestDocumentationScreenState();
}

class _RequestDocumentationScreenState extends State<RequestDocumentationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();

  PropertyType _selectedPropertyType = PropertyType.land;
  double? _latitude;
  double? _longitude;
  List<String> _documentUrls = [];
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Submit service request to backend
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documentation request submitted successfully')),
    );
    context.pop();
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyAddressController.dispose();
    _ownerNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<PropertyType>(
                value: _selectedPropertyType,
                decoration: const InputDecoration(
                  labelText: 'Property Type',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Property Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _propertyAddressController,
                decoration: const InputDecoration(
                  labelText: 'Property Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter property address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Property Owner Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter owner name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 300,
                child: MapLocationPicker(
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
              const SizedBox(height: 24),
              const Text(
                'Ownership Documents & Address Proof',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              FileUploadWidget(
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                maxFiles: 5,
                onFilesSelected: (files) {
                  setState(() => _documentUrls = files);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Request', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
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
