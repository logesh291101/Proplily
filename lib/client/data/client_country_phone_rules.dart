import 'package:proplilly/client/models/client_country_code.dart';

/// National phone number length rules keyed by [CountryCode.isoCode].
class CountryPhoneRules {
  CountryPhoneRules._();

  static const _defaultRule = CountryPhoneRule(minDigits: 6, maxDigits: 15);

  static const Map<String, CountryPhoneRule> _byIso = {
    'AF': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'US': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'GB': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'IN': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'PK': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'AE': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'SA': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'AU': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'DE': CountryPhoneRule(minDigits: 10, maxDigits: 11),
    'FR': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'JP': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'CN': CountryPhoneRule(minDigits: 11, maxDigits: 11),
    'ZA': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'NG': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'BD': CountryPhoneRule(minDigits: 10, maxDigits: 10),
    'LK': CountryPhoneRule(minDigits: 9, maxDigits: 9),
    'NP': CountryPhoneRule(minDigits: 10, maxDigits: 10),
  };

  static CountryPhoneRule forCountry(CountryCode country) {
    return _byIso[country.isoCode] ?? _defaultRule;
  }
}

class CountryPhoneRule {
  const CountryPhoneRule({
    required this.minDigits,
    required this.maxDigits,
  });

  final int minDigits;
  final int maxDigits;

  bool get hasExactLength => minDigits == maxDigits;
}
