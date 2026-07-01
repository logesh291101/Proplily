/// Plot size unit options for property registration.
class SizeUnits {
  SizeUnits._();

  static const List<String> all = [
    'sq.ft',
    'sq.m',
    'acre',
    'cent',
    'ground',
  ];

  static List<String> withSavedValue(String? saved) {
    final trimmed = saved?.trim();
    if (trimmed == null || trimmed.isEmpty || all.contains(trimmed)) {
      return all;
    }
    return [...all, trimmed];
  }
}
