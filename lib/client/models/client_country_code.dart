/// Dial code and label for the referral phone field dropdown.
class CountryCode {
  const CountryCode({
    required this.dialCode,
    required this.name,
    required this.isoCode,
  });

  final String dialCode;
  final String name;
  final String isoCode;

  String get displayLabel => '$dialCode ($name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          dialCode == other.dialCode &&
          isoCode == other.isoCode;

  @override
  int get hashCode => Object.hash(dialCode, isoCode);
}
