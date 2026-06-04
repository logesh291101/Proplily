import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Plot size input with sq.ft unit suffix.
class AddPropertySizeField extends StatelessWidget {
  const AddPropertySizeField({
    super.key,
    required this.controller,
    this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
      ],
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Plot Size *',
        hintText: 'e.g., 1200',
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: PremiumDecorations.iconTile(AppColors.primary),
            child: const Icon(
              Icons.square_foot_rounded,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 56, minHeight: 48),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            alignment: Alignment.center,
            width: 52,
            child: Text(
              'sq.ft',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 64),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
