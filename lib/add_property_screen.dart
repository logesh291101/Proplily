import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/data/india_locations.dart';
import 'package:proplilly/data/plot_types.dart';
import 'package:proplilly/services/property_service.dart';
import 'package:proplilly/theme/screen_spacing.dart';
import 'package:proplilly/utils/form_validators.dart';
import 'package:proplilly/widgets/add_property/add_property_documents_section.dart';
import 'package:proplilly/widgets/add_property/add_property_dropdown_field.dart';
import 'package:proplilly/widgets/add_property/add_property_hero_section.dart';
import 'package:proplilly/widgets/add_property/add_property_images_section.dart';
import 'package:proplilly/widgets/add_property/add_property_map_section.dart';
import 'package:proplilly/widgets/add_property/add_property_size_field.dart';
import 'package:proplilly/widgets/premium/premium_buttons.dart';
import 'package:proplilly/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/widgets/ui/modern_section_card.dart';

/// Premium property registration screen.
class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _plotSizeController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController(text: '20.593700');
  final _longitudeController = TextEditingController(text: '78.962900');
  final _ownerNameController = TextEditingController(text: 'sri');
  final _phoneController = TextEditingController(text: '9024403004');
  late final TextEditingController _countryController;

  final PropertyService _propertyService = PropertyService();

  String? _plotType;
  String? _state;
  String? _city;

  @override
  void initState() {
    super.initState();
    _countryController = TextEditingController(
      text: IndiaLocations.defaultCountry,
    );
  }

  List<String> _documentPaths = [];
  List<String> _imagePaths = [];
  bool _isSubmitting = false;

  List<String> get _availableCities => IndiaLocations.citiesForState(_state);

  @override
  void dispose() {
    _propertyNameController.dispose();
    _plotSizeController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onCancel() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  Future<void> _onRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_plotType == null) {
      _showMessage('Please select a plot type', isError: true);
      return;
    }
    if (_state == null) {
      _showMessage('Please select a state', isError: true);
      return;
    }
    if (_city == null) {
      _showMessage('Please select a city', isError: true);
      return;
    }
    if (_documentPaths.isEmpty) {
      _showMessage('Please add at least one document', isError: true);
      return;
    }
    if (_imagePaths.isEmpty) {
      _showMessage('Please add at least one property photo', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _propertyService.registerProperty(
        propertyName: _propertyNameController.text.trim(),
        plotType: _plotType!,
        plotSize: _plotSizeController.text.trim(),
        country: _countryController.text.trim(),
        state: _state!,
        city: _city!,
        fullAddress: _addressController.text.trim(),
        latitude: double.parse(_latitudeController.text.trim()),
        longitude: double.parse(_longitudeController.text.trim()),
        ownerName: _ownerNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        documentPaths: _documentPaths,
        imagePaths: _imagePaths,
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
                            hint: 'e.g., test234 plot',
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
                            value: _plotType,
                            items: PlotTypes.all
                                .map(
                                  (t) => DropdownMenuItem(value: t, child: Text(t)),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _plotType = v),
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
                      child: Column(
                        children: [
                          AbsorbPointer(
                            child: ClientReferralPremiumField(
                              controller: _countryController,
                              label: 'Country *',
                              hint: IndiaLocations.defaultCountry,
                              icon: Icons.flag_outlined,
                            ),
                          ),
                          const SizedBox(height: 18),
                          AddPropertyDropdownField<String>(
                            label: 'State *',
                            hint: 'Select State',
                            icon: Icons.map_outlined,
                            value: _state,
                            items: IndiaLocations.states
                                .map(
                                  (s) =>
                                      DropdownMenuItem(value: s, child: Text(s)),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _state = v;
                              _city = null;
                            }),
                          ),
                          const SizedBox(height: 18),
                          AddPropertyDropdownField<String>(
                            label: 'City *',
                            hint: 'Select City',
                            icon: Icons.location_city_outlined,
                            value: _city,
                            enabled: _state != null,
                            items: _availableCities
                                .map(
                                  (c) =>
                                      DropdownMenuItem(value: c, child: Text(c)),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _city = v),
                          ),
                          const SizedBox(height: 18),
                          ClientReferralPremiumField(
                            controller: _addressController,
                            label: 'Full Address *',
                            hint: 'Street, Landmark...',
                            icon: Icons.home_outlined,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            validator: (v) => FormValidators.requiredField(
                              v,
                              fieldName: 'a full address',
                            ),
                          ),
                          const SizedBox(height: 22),
                          AddPropertyMapSection(
                            latitudeController: _latitudeController,
                            longitudeController: _longitudeController,
                          ),
                        ],
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
                            hint: '9024403004',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: FormValidators.phoneNumber,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ModernSectionCard(
                      title: 'Documents & Photos',
                      titleIcon: Icons.folder_copy_outlined,
                      child: Column(
                        children: [
                          AddPropertyDocumentsSection(
                            documentPaths: _documentPaths,
                            onDocumentsChanged: (paths) =>
                                setState(() => _documentPaths = paths),
                          ),
                          const SizedBox(height: 24),
                          AddPropertyImagesSection(
                            imagePaths: _imagePaths,
                            onImagesChanged: (paths) =>
                                setState(() => _imagePaths = paths),
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
          const SizedBox(height: 12),
          PremiumOutlineButton(
            label: 'Cancel',
            onPressed: isSubmitting ? null : onCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: PremiumOutlineButton(
            label: 'Cancel',
            onPressed: isSubmitting ? null : onCancel,
          ),
        ),
        const SizedBox(width: 14),
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
