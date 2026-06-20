import 'package:proplilly/client/data/client_country_phone_rules.dart';
import 'package:proplilly/client/models/client_country_code.dart';

/// Shared validators for app forms.
class FormValidators {
  FormValidators._();

  static String? referralName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Referral name is required.';
    }
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? fullName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a full name';
    }
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter an email address';
    }
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a phone number';
    }
    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 6) {
      return 'Phone number is too short';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  static String? phoneForCountry(
    String? value,
    CountryCode country, {
    String emptyMessage = 'Please enter a phone number',
    String fieldLabel = 'Phone number',
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return emptyMessage;
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    final rule = CountryPhoneRules.forCountry(country);

    if (digitsOnly.length < rule.minDigits) {
      return _phoneLengthMessage(
        country: country,
        rule: rule,
        fieldLabel: fieldLabel,
      );
    }

    if (digitsOnly.length > rule.maxDigits) {
      return _phoneLengthMessage(
        country: country,
        rule: rule,
        fieldLabel: fieldLabel,
      );
    }

    return null;
  }

  static String? ownerPhoneForCountry(String? value, CountryCode country) {
    return phoneForCountry(
      value,
      country,
      emptyMessage: 'Owner phone is required.',
      fieldLabel: 'Owner phone',
    );
  }

  static String _phoneLengthMessage({
    required CountryCode country,
    required CountryPhoneRule rule,
    required String fieldLabel,
  }) {
    if (rule.hasExactLength) {
      return 'Enter exactly ${rule.maxDigits} digits for ${country.name}.';
    }
    return '$fieldLabel must be ${rule.minDigits}-${rule.maxDigits} digits for ${country.name}.';
  }

  static String? requiredField(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  static String? requiredLabel(String? value, {required String label}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required.';
    }
    return null;
  }

  static String? ownerName(String? value) {
    return requiredLabel(value, label: 'Owner name');
  }

  static String? ownerPhone(String? value, CountryCode country) {
    return ownerPhoneForCountry(value, country);
  }

  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required.';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Invalid latitude';
    }
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required.';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Invalid longitude';
    }
    return null;
  }

  static String? requiredDropdown<T>(T? value, {required String fieldName}) {
    if (value == null) {
      return '$fieldName is required.';
    }
    if (value is String && value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? detailedMessage(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a message';
    }
    if (trimmed.length < 10) {
      return 'Please provide more detail (at least 10 characters)';
    }
    return null;
  }
}
