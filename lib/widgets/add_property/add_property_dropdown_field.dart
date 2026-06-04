import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Premium dropdown matching referral/support form styling.
class AddPropertyDropdownField<T> extends StatelessWidget {
  const AddPropertyDropdownField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
          ),
        ),
      ),
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );
  }
}
