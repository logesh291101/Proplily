import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/data/country_codes.dart';
import 'package:proplilly/models/country_code.dart';
import 'package:proplilly/theme/premium_decorations.dart';
import 'package:proplilly/utils/form_validators.dart';

/// Country code dropdown + phone field for [ClientReferralScreen].
class ClientReferralPhoneField extends StatelessWidget {
  const ClientReferralPhoneField({
    super.key,
    required this.phoneController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  final TextEditingController phoneController;
  final CountryCode selectedCountry;
  final ValueChanged<CountryCode> onCountryChanged;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
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
                onChanged: (c) {
                  if (c != null) onCountryChanged(c);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-()+]')),
                ],
                validator: FormValidators.phoneNumber,
                decoration: _fieldDecoration(
                  hint: 'Phone number',
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
