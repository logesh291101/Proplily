import 'package:flutter/material.dart';
import 'package:proplilly/client/data/client_country_codes.dart';
import 'package:proplilly/client/data/client_plot_types.dart';
import 'package:proplilly/client/data/client_size_units.dart';
import 'package:proplilly/client/models/client_country_code.dart';
import 'package:proplilly/client/services/client_property_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_documents_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_dropdown_field.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_hero_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_images_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_location_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_size_field.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_phone_field.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

/// Premium property registration screen.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerPhoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _propertyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _plotSizeController = TextEditingController();

  final PropertyService _propertyService = PropertyService();

  String? _plotType;
  String? _sizeUnit;
  String? _country;
  String? _state;
  String? _city;
  CountryCode _selectedCountry = CountryCodes.defaultCountry;

  List<String> _documentPaths = [];
  List<String> _imagePaths = [];
  String? _imagesError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _plotSizeController.dispose();
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

  void _onCancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  String _ownerPhoneValue() {
    return _phoneController.text.replaceAll(RegExp(r'\D'), '');
  }

  bool _validateImages() {
    if (_imagePaths.isEmpty) {
      setState(() {
        _imagesError = 'Please upload at least one property image.';
      });
      return false;
    }
    setState(() => _imagesError = null);
    return true;
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    final imagesValid = _validateImages();
    if (!formValid || !imagesValid) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _propertyService.registerProperty(
        propertyName: _propertyNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _city!,
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        ownerPhone: _ownerPhoneValue(),
        plotType: _plotType!,
        country: _country!,
        state: _state!,
        plotSize: _plotSizeController.text.trim(),
        sizeUnit: _sizeUnit!,
        imagePaths: _imagePaths,
        documentPaths: _documentPaths,
      );
      if (!mounted) return;

      switch (result) {
        case PropertyRegistrationSuccess(:final message):
          _showMessage(message, isError: false);
          Navigator.of(context).pop();
        case PropertyRegistrationFailure(:final message):
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
                      title: 'Property Information',
                      titleIcon: Icons.home_work_outlined,
                      child: Column(
                        children: [
                          ClientReferralPremiumField(
                            controller: _propertyNameController,
                            label: 'Property Name *',
                            hint: 'Enter property name',
                            icon: Icons.badge_outlined,
                            validator: (v) => FormValidators.requiredLabel(
                              v,
                              label: 'Property name',
                            ),
                          ),
                          const SizedBox(height: 18),
                          ClientReferralPremiumField(
                            controller: _addressController,
                            label: 'Address *',
                            hint: 'Street, landmark...',
                            icon: Icons.home_outlined,
                            maxLines: 3,
                            textInputAction: TextInputAction.newline,
                            validator: (v) => FormValidators.requiredLabel(
                              v,
                              label: 'Address',
                            ),
                          ),
                          const SizedBox(height: 18),
                          AddPropertyLocationSection(
                            country: _country,
                            state: _state,
                            city: _city,
                            latitudeController: _latitudeController,
                            longitudeController: _longitudeController,
                            onCountryChanged: _onCountryChanged,
                            onStateChanged: _onStateChanged,
                            onCityChanged: (value) =>
                                setState(() => _city = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Owner Information',
                      titleIcon: Icons.person_outline_rounded,
                      child: Column(
                        children: [
                          ClientReferralPremiumField(
                            controller: _ownerNameController,
                            label: 'Owner Name *',
                            hint: 'Enter owner name',
                            icon: Icons.person_outline_rounded,
                            validator: FormValidators.ownerName,
                          ),
                          const SizedBox(height: 18),
                          ClientReferralPhoneField(
                            phoneFieldKey: _ownerPhoneFieldKey,
                            phoneController: _phoneController,
                            selectedCountry: _selectedCountry,
                            onCountryChanged: (country) =>
                                setState(() => _selectedCountry = country),
                            label: 'Owner Phone *',
                            emptyMessage: 'Owner phone is required.',
                            fieldLabel: 'Owner phone',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Property Details',
                      titleIcon: Icons.category_outlined,
                      child: Column(
                        children: [
                          AddPropertyDropdownField<String>(
                            label: 'Plot Type *',
                            hint: 'Select plot type',
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
                            validator: (v) => FormValidators.requiredLabel(
                              v,
                              label: 'Plot size',
                            ),
                          ),
                          const SizedBox(height: 18),
                          AddPropertyDropdownField<String>(
                            label: 'Size Unit *',
                            hint: 'Select size unit',
                            icon: Icons.straighten_rounded,
                            value: _sizeUnit,
                            items: SizeUnits.all
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _sizeUnit = v),
                            validator: (v) => FormValidators.requiredDropdown(
                              v,
                              fieldName: 'Size unit',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Uploads',
                      titleIcon: Icons.folder_copy_outlined,
                      child: Column(
                        children: [
                          AddPropertyImagesSection(
                            imagePaths: _imagePaths,
                            errorText: _imagesError,
                            onImagesChanged: (paths) => setState(() {
                              _imagePaths = paths;
                              if (paths.isNotEmpty) {
                                _imagesError = null;
                              }
                            }),
                          ),
                          const SizedBox(height: 24),
                          AddPropertyDocumentsSection(
                            documentPaths: _documentPaths,
                            onDocumentsChanged: (paths) =>
                                setState(() => _documentPaths = paths),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    _ActionButtons(
                      isSubmitting: _isSubmitting,
                      onCancel: _onCancel,
                      onRegister: _onRegister,
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isSubmitting,
    required this.onCancel,
    required this.onRegister,
  });

  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 400;

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumPrimaryButton(
            label: 'Register Asset',
            icon: Icons.check_circle_outline_rounded,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onRegister,
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PremiumPrimaryButton(
            label: 'Register Asset',
            icon: Icons.check_circle_outline_rounded,
            isLoading: isSubmitting,
            onPressed: isSubmitting ? null : onRegister,
          ),
        ),
      ],
    );
  }
}
