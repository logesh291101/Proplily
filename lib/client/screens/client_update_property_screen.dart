import 'package:flutter/material.dart';
import 'package:proplilly/client/data/client_plot_types.dart';
import 'package:proplilly/client/data/client_property_locations.dart';
import 'package:proplilly/client/data/client_size_units.dart';
import 'package:proplilly/client/models/client_properties_detail_model.dart';
import 'package:proplilly/client/models/client_property_extensions.dart';
import 'package:proplilly/client/services/client_property_detail_service.dart';
import 'package:proplilly/client/services/client_property_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_dropdown_field.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_hero_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_location_section.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_size_field.dart';
import 'package:proplilly/client/widgets/client_add_property/client_update_property_media_sections.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/premium/premium_error_state.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';

/// Updates an existing property from the My Properties flow.
class ClientUpdatePropertyScreen extends StatefulWidget {
  const ClientUpdatePropertyScreen({
    super.key,
    required this.propertyId,
  });

  final String propertyId;

  @override
  State<ClientUpdatePropertyScreen> createState() =>
      _ClientUpdatePropertyScreenState();
}

class _ClientUpdatePropertyScreenState extends State<ClientUpdatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyService = PropertyService();
  final _detailService = ClientPropertyDetailService();

  late final TextEditingController _propertyNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _plotSizeController;

  String? _plotType;
  String? _sizeUnit;
  String? _country;
  String? _state;
  String? _city;

  List<String> _existingImageUrls = [];
  List<String> _existingDocumentUrls = [];
  List<String> _newImagePaths = [];
  List<String> _newDocumentPaths = [];

  String? _imagesError;
  bool _isSubmitting = false;
  bool _isLoadingDetail = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _propertyNameController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _plotSizeController = TextEditingController();
    _loadPropertyDetail();
  }

  Future<void> _loadPropertyDetail() async {
    setState(() {
      _isLoadingDetail = true;
      _loadError = null;
    });

    final result =
        await _detailService.fetchPropertyDetail(widget.propertyId);
    if (!mounted) return;

    switch (result) {
      case ClientPropertyDetailFetchSuccess(:final data):
        _applyDetailData(data);
        setState(() {
          _isLoadingDetail = false;
          _loadError = null;
        });
      case ClientPropertyDetailFetchFailure(:final message):
        setState(() {
          _isLoadingDetail = false;
          _loadError = message;
        });
    }
  }

  void _applyDetailData(ClientPropertyDetailData data) {
    final details = data.details;

    _propertyNameController.text = details.propertyName.trim();
    _addressController.text = details.address.trim();
    _latitudeController.text = details.latitude.trim();
    _longitudeController.text = details.longitude.trim();
    _plotSizeController.text = details.plotSize.trim();

    _plotType = PlotTypes.dropdownValue(
      details.plotType.isNotEmpty ? details.plotType : details.propertyType,
    );
    _sizeUnit =
        details.sizeUnit.trim().isNotEmpty ? details.sizeUnit.trim() : null;
    _state = details.state.trim().isNotEmpty ? details.state.trim() : null;
    _city = details.city.trim().isNotEmpty ? details.city.trim() : null;
    _country = null;

    _existingImageUrls = List<String>.from(data.imageUrls);
    _existingDocumentUrls = List<String>.from(data.documentUrls);

    _resolveCountry();
  }

  Future<void> _resolveCountry() async {
    await PropertyLocations.ensureLoaded();
    if (!mounted) return;

    final resolved = PropertyLocations.countryForState(_state ?? '');

    if (resolved != null && resolved.trim().isNotEmpty) {
      setState(() => _country = resolved.trim());
    }
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
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

  bool _validateImages() {
    final totalImages = _existingImageUrls.length + _newImagePaths.length;
    if (totalImages == 0) {
      setState(() {
        _imagesError = 'Please keep or upload at least one property image.';
      });
      return false;
    }
    setState(() => _imagesError = null);
    return true;
  }

  Future<void> _onUpdate() async {
    FocusScope.of(context).unfocus();
    final formValid = _formKey.currentState?.validate() ?? false;
    final imagesValid = _validateImages();
    if (!formValid || !imagesValid) return;

    setState(() => _isSubmitting = true);
    try {
      final result = await _propertyService.updateClientProperty(
        propertyId: widget.propertyId,
        propertyName: _propertyNameController.text.trim(),
        address: _addressController.text.trim(),
        city: _city!,
        latitude: _latitudeController.text.trim(),
        longitude: _longitudeController.text.trim(),
        plotType: _plotType!,
        country: _country!,
        state: _state!,
        plotSize: _plotSizeController.text.trim(),
        sizeUnit: _sizeUnit!,
        imagePaths: _newImagePaths,
        documentPaths: _newDocumentPaths,
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
    final sizeUnitOptions = SizeUnits.withSavedValue(_sizeUnit);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ProplillyAppBar.clientHeroOverlay(),
      body: Column(
        children: [
          const AddPropertyHeroSection(
            title: 'Update Property',
            subtitle: 'Edit your property details and upload new files.',
            icon: Icons.edit_outlined,
          ),
          Expanded(
            child: _isLoadingDetail
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _loadError != null
                    ? PremiumErrorState(
                        message: _loadError!,
                        onRetry: _loadPropertyDetail,
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding:
                            EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32),
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
                                      validator: (v) =>
                                          FormValidators.requiredLabel(
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
                                      validator: (v) =>
                                          FormValidators.requiredLabel(
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
                                      onChanged: (v) =>
                                          setState(() => _plotType = v),
                                      validator: (v) =>
                                          FormValidators.requiredDropdown(
                                        v,
                                        fieldName: 'Plot type',
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    AddPropertySizeField(
                                      controller: _plotSizeController,
                                      validator: (v) =>
                                          FormValidators.requiredLabel(
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
                                      items: sizeUnitOptions
                                          .map(
                                            (unit) => DropdownMenuItem(
                                              value: unit,
                                              child: Text(unit),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (v) =>
                                          setState(() => _sizeUnit = v),
                                      validator: (v) =>
                                          FormValidators.requiredDropdown(
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
                                    UpdatePropertyImagesSection(
                                      existingImageUrls: _existingImageUrls,
                                      newImagePaths: _newImagePaths,
                                      errorText: _imagesError,
                                      onExistingChanged: (urls) => setState(
                                          () => _existingImageUrls = urls),
                                      onNewImagesChanged: (paths) => setState(() {
                                        _newImagePaths = paths;
                                        if (_existingImageUrls.isNotEmpty ||
                                            paths.isNotEmpty) {
                                          _imagesError = null;
                                        }
                                      }),
                                    ),
                                    const SizedBox(height: 24),
                                    UpdatePropertyDocumentsSection(
                                      existingDocumentUrls:
                                          _existingDocumentUrls,
                                      newDocumentPaths: _newDocumentPaths,
                                      onExistingChanged: (urls) => setState(
                                          () => _existingDocumentUrls = urls),
                                      onNewDocumentsChanged: (paths) =>
                                          setState(
                                              () => _newDocumentPaths = paths),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 26),
                              PremiumPrimaryButton(
                                label: 'Update Details',
                                icon: Icons.check_circle_outline_rounded,
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _onUpdate,
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
