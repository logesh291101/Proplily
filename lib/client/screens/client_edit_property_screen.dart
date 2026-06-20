import 'package:flutter/material.dart';
import 'package:proplilly/client/data/client_plot_types.dart';
import 'package:proplilly/client/data/client_property_locations.dart';
import 'package:proplilly/client/models/client_property_status_model.dart';
import 'package:proplilly/client/services/client_property_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_dropdown_field.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_hero_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_location_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_size_field.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

/// Edit an existing property with cascading location dropdowns.
class EditPropertyScreen extends StatefulWidget {
  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  final ClientPropertyStatusItem property;

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyService = PropertyService();

  late final TextEditingController _propertyNameController;
  late final TextEditingController _plotSizeController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;

  late String? _plotType;
  late String? _country;
  late String? _state;
  late String? _city;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final property = widget.property;

    _propertyNameController = TextEditingController(text: property.propertyName);
    _plotSizeController = TextEditingController(text: property.plotSize);
    _addressController = TextEditingController(text: property.address);
    _latitudeController = TextEditingController(
      text: property.latitude.isNotEmpty ? property.latitude : '20.593700',
    );
    _longitudeController = TextEditingController(
      text: property.longitude.isNotEmpty ? property.longitude : '78.962900',
    );
    _ownerNameController = TextEditingController(text: property.ownerName);
    _phoneController = TextEditingController(text: property.ownerPhone);

    _plotType = PlotTypes.normalize(property.propertyType);
    _state = property.state.trim().isNotEmpty ? property.state.trim() : null;
    _city = property.city.trim().isNotEmpty ? property.city.trim() : null;
    _country = property.country.trim().isNotEmpty ? property.country.trim() : null;
    _resolveCountryIfNeeded();
  }

  Future<void> _resolveCountryIfNeeded() async {
    if (_country != null && _country!.isNotEmpty) return;

    await PropertyLocations.ensureLoaded();
    final resolved = PropertyLocations.countryForState(widget.property.state);
    if (!mounted || resolved == null) return;

    setState(() => _country = resolved);
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _plotSizeController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String? value) {
    setState(() {
      _country = value;
      _state = null;
      _city = null;
    });
  }

  void _onStateChanged(String? value) {
    setState(() {
      _state = value;
      _city = null;
    });
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_plotType == null) {
      _showMessage('Please select a plot type', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _propertyService.updateProperty(
        propertyId: widget.property.propertyId,
        propertyName: _propertyNameController.text.trim(),
        plotType: _plotType!,
        plotSize: _plotSizeController.text.trim(),
        country: _country!,
        state: _state!,
        city: _city!,
        fullAddress: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        ownerName: _ownerNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      if (!mounted) return;

      switch (result) {
        case PropertyUpdateSuccess(:final message):
          _showMessage(message, isError: false);
          Navigator.of(context).pop(true);
        case PropertyUpdateFailure(:final message):
          _showMessage(message, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: Column(
        children: [
          const AddPropertyHeroSection(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ModernSectionCard(
                      title: 'Property Details',
                      titleIcon: Icons.home_work_outlined,
                      child: Column(
                        children: [
                          ClientReferralPremiumField(
                            controller: _propertyNameController,
                            label: 'Property Name *',
                            hint: '',
                            icon: Icons.badge_outlined,
                            validator: (v) => FormValidators.requiredField(
                              v,
                              fieldName: 'a property name',
                            ),
                          ),
                          const SizedBox(height: 18),
                          AddPropertyDropdownField<String>(
                            label: 'Plot Type *',
                            hint: 'Select Plot Type',
                            icon: Icons.category_outlined,
                            value: PlotTypes.dropdownValue(_plotType),
                            items: PlotTypes.addPropertyOptions
                                .map(
                                  (option) => DropdownMenuItem(
                                    value: option.value,
                                    child: Text(option.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _plotType = v),
                            validator: (v) => FormValidators.requiredDropdown(
                              v,
                              fieldName: 'Plot type',
                            ),
                          ),
                          const SizedBox(height: 18),
                          AddPropertySizeField(
                            controller: _plotSizeController,
                            validator: (v) => FormValidators.requiredField(
                              v,
                              fieldName: 'plot size',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Location',
                      titleIcon: Icons.place_outlined,
                      child: AddPropertyLocationSection(
                        country: _country,
                        state: _state,
                        city: _city,
                        addressController: _addressController,
                        latitudeController: _latitudeController,
                        longitudeController: _longitudeController,
                        onCountryChanged: _onCountryChanged,
                        onStateChanged: _onStateChanged,
                        onCityChanged: (value) => setState(() => _city = value),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Owner Details',
                      titleIcon: Icons.person_outline_rounded,
                      child: Column(
                        children: [
                          ClientReferralPremiumField(
                            controller: _ownerNameController,
                            label: 'Owner Name *',
                            hint: 'Enter owner name',
                            icon: Icons.person_outline_rounded,
                            validator: FormValidators.fullName,
                          ),
                          const SizedBox(height: 18),
                          ClientReferralPremiumField(
                            controller: _phoneController,
                            label: 'Phone Number *',
                            hint: '',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: FormValidators.phoneNumber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    PremiumPrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.save_outlined,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _onSave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
