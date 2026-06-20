import 'package:flutter/material.dart';
import 'package:proplilly/client/data/client_property_locations.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_dropdown_field.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_map_section.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';

/// Cascading Country → State → City fields with optional address and map.
class AddPropertyLocationSection extends StatefulWidget {
  const AddPropertyLocationSection({
    super.key,
    required this.country,
    required this.state,
    required this.city,
    required this.latitudeController,
    required this.longitudeController,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    this.addressController,
  });

  final String? country;
  final String? state;
  final String? city;
  final TextEditingController? addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;

  @override
  State<AddPropertyLocationSection> createState() =>
      _AddPropertyLocationSectionState();
}

class _AddPropertyLocationSectionState extends State<AddPropertyLocationSection> {
  bool _isLoadingLocations = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    await PropertyLocations.ensureLoaded();
    if (mounted) {
      setState(() => _isLoadingLocations = false);
    }
  }

  List<String> get _stateOptions => PropertyLocations.withSavedValue(
        PropertyLocations.statesForCountry(widget.country),
        widget.state,
      );

  List<String> get _cityOptions => PropertyLocations.withSavedValue(
        PropertyLocations.citiesForState(widget.country, widget.state),
        widget.city,
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocations) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Column(
      children: [
        AddPropertyDropdownField<String>(
          label: 'Country *',
          hint: 'Select Country',
          icon: Icons.flag_outlined,
          value: widget.country,
          items: PropertyLocations.countries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: widget.onCountryChanged,
          validator: (v) => FormValidators.requiredDropdown(
            v,
            fieldName: 'Country',
          ),
        ),
        const SizedBox(height: 18),
        AddPropertyDropdownField<String>(
          label: 'State *',
          hint: 'Select State',
          icon: Icons.map_outlined,
          value: widget.state,
          enabled: widget.country != null,
          items: _stateOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: widget.onStateChanged,
          validator: (v) => FormValidators.requiredDropdown(
            v,
            fieldName: 'State',
          ),
        ),
        const SizedBox(height: 18),
        AddPropertyDropdownField<String>(
          label: 'City *',
          hint: 'Select City',
          icon: Icons.location_city_outlined,
          value: widget.city,
          enabled: widget.state != null,
          items: _cityOptions
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: widget.onCityChanged,
          validator: (v) => FormValidators.requiredDropdown(
            v,
            fieldName: 'City',
          ),
        ),
        if (widget.addressController != null) ...[
          const SizedBox(height: 18),
          ClientReferralPremiumField(
            controller: widget.addressController!,
            label: 'Full Address *',
            hint: 'Street, Landmark...',
            icon: Icons.home_outlined,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
            validator: (v) => FormValidators.requiredLabel(v, label: 'Address'),
          ),
        ],
        const SizedBox(height: 22),
        AddPropertyMapSection(
          latitudeController: widget.latitudeController,
          longitudeController: widget.longitudeController,
        ),
      ],
    );
  }
}
