import 'package:flutter/material.dart';
import 'package:proplilly/client/data/client_additional_service_categories.dart';
import 'package:proplilly/client/services/client_additional_services_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/theme/screen_spacing.dart';
import 'package:proplilly/client/utils/form_validators.dart';
import 'package:proplilly/client/widgets/client_add_property/client_add_property_dropdown_field.dart';
import 'package:proplilly/client/widgets/client_referral/client_referral_premium_field.dart';
import 'package:proplilly/client/widgets/premium/premium_buttons.dart';
import 'package:proplilly/client/widgets/proplilly_app_bar_logo_action.dart';
import 'package:proplilly/client/widgets/ui/modern_section_card.dart';
import 'package:proplilly/client/widgets/ui/proplilly_screen_hero_section.dart';

class ClientRequestAdditionalServiceScreen extends StatefulWidget {
  const ClientRequestAdditionalServiceScreen({super.key});

  @override
  State<ClientRequestAdditionalServiceScreen> createState() =>
      _ClientRequestAdditionalServiceScreenState();
}

class _ClientRequestAdditionalServiceScreenState
    extends State<ClientRequestAdditionalServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _service = ClientAdditionalServicesService();

  String? _selectedServiceType;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _showApiSnackBar({
    required String message,
    required Color backgroundColor,
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false) || _isSubmitting) {
      return;
    }

    final commentsText = _commentsController.text.trim();
    final comments = commentsText.isEmpty ? null : commentsText;

    setState(() => _isSubmitting = true);
    try {
      final result = await _service.submitAdditionalService(
        serviceType: ClientAdditionalServiceCategories.formatLabel(
          _selectedServiceType!,
        ),
        comments: comments,
      );

      if (!mounted) return;

      switch (result) {
        case ClientAdditionalServiceSubmitSuccess(:final message):
          _showApiSnackBar(
            message: message,
            backgroundColor: AppColors.success,
          );
          Navigator.of(context).pop(true);
        case ClientAdditionalServiceSubmitFailure(:final message):
          _showApiSnackBar(
            message: message,
            backgroundColor: AppColors.error,
          );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = ScreenSpacing.horizontal(context);
    final selectedServiceType =
        ClientAdditionalServiceCategories.matchOption(_selectedServiceType);
    final dropdownItems = ClientAdditionalServiceCategories.options
        .map(
          (option) => DropdownMenuItem(
            value: option,
            child: Text(
              ClientAdditionalServiceCategories.formatLabel(option),
            ),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Service'),
        actions: ProplillyAppBar.clientActions(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProplillyScreenHeroSection(
            title: 'Request Additional Service',
            subtitle: 'Select a service and provide details below.',
            icon: Icons.add_circle_outline_rounded,
          ),
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
                      title: 'Service Request',
                      titleIcon: Icons.home_repair_service_outlined,
                      child: Column(
                        children: [
                          AddPropertyDropdownField<String>(
                            label: 'Service Category *',
                            hint: 'Select a service',
                            icon: Icons.category_outlined,
                            value: selectedServiceType,
                            items: dropdownItems,
                            onChanged: _isSubmitting
                                ? null
                                : (value) => setState(
                                      () => _selectedServiceType = value,
                                    ),
                            enabled: !_isSubmitting,
                            validator: (value) =>
                                FormValidators.requiredDropdown(
                              value,
                              fieldName: 'Service category',
                            ),
                          ),
                          const SizedBox(height: 18),
                          ClientReferralPremiumField(
                            controller: _commentsController,
                            label: 'Additional Comments',
                            hint: 'Any specific requirements or questions?',
                            icon: Icons.notes_outlined,
                            maxLines: 5,
                            textInputAction: TextInputAction.newline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    PremiumPrimaryButton(
                      label: 'Submit Request',
                      icon: Icons.send_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _onSubmit,
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
