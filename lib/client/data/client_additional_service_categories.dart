/// Predefined service categories for additional service requests.
class ClientAdditionalServiceCategories {
  ClientAdditionalServiceCategories._();

  static const List<String> options = [
    'Extra field visit',
    'Buy a property',
    'Sell a property',
    'Legal assistance',
    'Others',
  ];

  /// First letter uppercase, remaining letters lowercase.
  static String formatLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.length == 1) return trimmed.toUpperCase();
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1).toLowerCase()}';
  }

  /// Maps a stored/API value to the canonical dropdown option, if possible.
  static String? matchOption(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    for (final option in options) {
      if (option == trimmed) return option;
      if (option.toLowerCase() == trimmed.toLowerCase()) return option;
    }

    return null;
  }
}
