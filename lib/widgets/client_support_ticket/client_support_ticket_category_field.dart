import 'package:flutter/material.dart';
import 'package:proplilly/app_colors.dart';
import 'package:proplilly/models/client_support_ticket_model.dart';
import 'package:proplilly/theme/premium_decorations.dart';

/// Styled category dropdown for client support tickets.
class ClientSupportTicketCategoryField extends StatelessWidget {
  const ClientSupportTicketCategoryField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: const Text('Select a category'),
      isExpanded: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: 'Category',
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
              Icons.category_outlined,
              color: AppColors.primaryDark,
              size: 20,
            ),
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
      ),
      items: ClientSupportTicketContent.ticketCategories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
      validator: (selected) {
        if (selected == null || selected.trim().isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }
}
