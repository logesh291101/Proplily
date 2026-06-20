import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/data/client_country_codes.dart';
import 'package:proplilly/client/data/client_country_phone_rules.dart';
import 'package:proplilly/client/models/client_country_code.dart';
import 'package:proplilly/client/theme/premium_decorations.dart';
import 'package:proplilly/client/utils/form_validators.dart';

/// Country code dropdown + phone field with country-aware validation.
class ClientReferralPhoneField extends StatelessWidget {
  const ClientReferralPhoneField({
    super.key,
    required this.phoneController,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.label = 'Phone Number',
    this.validator,
    this.emptyMessage,
    this.fieldLabel,
    this.phoneFieldKey,
  });

  final TextEditingController phoneController;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountryChanged;
  final String label;
  final String? Function(String?)? validator;
  final String? emptyMessage;
  final String? fieldLabel;
  final GlobalKey<FormFieldState<String>>? phoneFieldKey;

  InputDecoration _fieldDecoration({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  String? _validatePhone(String? value) {
    if (validator != null) {
      return validator!(value);
    }
    return FormValidators.phoneForCountry(
      value,
      selectedCountry,
      emptyMessage: emptyMessage ?? 'Please enter a phone number',
      fieldLabel: fieldLabel ?? 'Phone number',
    );
  }

  void _handleCountryChanged(CountryCode? country) {
    if (country == null) return;
    onCountryChanged(country);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      phoneFieldKey?.currentState?.validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rule = CountryPhoneRules.forCountry(selectedCountry);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 108,
              child: DropdownButtonFormField<CountryCode>(
                value: selectedCountry,
                isExpanded: true,
                decoration: _fieldDecoration(),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primaryDark,
                ),
                items: CountryCodes.all
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.dialCode,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _handleCountryChanged,
                validator: (value) {
                  if (value == null || value.dialCode.trim().isEmpty) {
                    return 'Country code is required.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                key: phoneFieldKey,
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(rule.maxDigits),
                ],
                validator: _validatePhone,
                decoration: _fieldDecoration(
                  hint: rule.hasExactLength
                      ? '${rule.maxDigits}-digit number'
                      : '${rule.minDigits}-${rule.maxDigits} digits',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: PremiumDecorations.iconTile(AppColors.primary),
                      child: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
