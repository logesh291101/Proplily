import 'package:proplilly/models/country_code.dart';

/// Supported country dial codes for the referral form.
class CountryCodes {
  CountryCodes._();

  static const CountryCode defaultCountry = CountryCode(
    dialCode: '+93',
    name: 'Afghanistan',
    isoCode: 'AF',
  );

  static const List<CountryCode> all = [
    defaultCountry,
    CountryCode(dialCode: '+1', name: 'United States', isoCode: 'US'),
    CountryCode(dialCode: '+44', name: 'United Kingdom', isoCode: 'GB'),
    CountryCode(dialCode: '+91', name: 'India', isoCode: 'IN'),
    CountryCode(dialCode: '+92', name: 'Pakistan', isoCode: 'PK'),
    CountryCode(dialCode: '+971', name: 'United Arab Emirates', isoCode: 'AE'),
    CountryCode(dialCode: '+966', name: 'Saudi Arabia', isoCode: 'SA'),
    CountryCode(dialCode: '+61', name: 'Australia', isoCode: 'AU'),
    CountryCode(dialCode: '+49', name: 'Germany', isoCode: 'DE'),
    CountryCode(dialCode: '+33', name: 'France', isoCode: 'FR'),
    CountryCode(dialCode: '+81', name: 'Japan', isoCode: 'JP'),
    CountryCode(dialCode: '+86', name: 'China', isoCode: 'CN'),
    CountryCode(dialCode: '+27', name: 'South Africa', isoCode: 'ZA'),
    CountryCode(dialCode: '+234', name: 'Nigeria', isoCode: 'NG'),
    CountryCode(dialCode: '+880', name: 'Bangladesh', isoCode: 'BD'),
    CountryCode(dialCode: '+94', name: 'Sri Lanka', isoCode: 'LK'),
    CountryCode(dialCode: '+977', name: 'Nepal', isoCode: 'NP'),
  ];
}
