/// Plot type options for property registration.
class PlotTypes {
  PlotTypes._();

  static const List<PlotTypeOption> addPropertyOptions = [
    PlotTypeOption(label: 'Residential', value: 'Residential'),
    PlotTypeOption(label: 'Commercial', value: 'Commercial'),
    PlotTypeOption(label: 'Agricultural', value: 'Agricultural'),
  ];

  static const Map<String, String> _legacyLabels = {
    'residential': 'Residential',
    'residential plot': 'Residential',
    'commercial': 'Commercial',
    'commercial plot': 'Commercial',
    'agricultural': 'Agricultural',
    'agricultural land': 'Agricultural',
    'industrial plot': 'Commercial',
    'villa plot': 'Residential',
    'row house': 'Residential',
    'apartment / flat': 'Residential',
    'farmhouse': 'Agricultural',
  };

  /// Maps API values, labels, and legacy plot type strings to a canonical value.
  static String? normalize(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return null;

    for (final option in addPropertyOptions) {
      if (option.value == trimmed) return option.value;
      if (option.label.toLowerCase() == trimmed.toLowerCase()) {
        return option.value;
      }
    }

    return _legacyLabels[trimmed.toLowerCase()];
  }

  /// Returns [raw] only when it matches a current dropdown option value.
  static String? dropdownValue(String? raw) {
    final normalized = normalize(raw);
    if (normalized == null) return null;

    final isSupported = addPropertyOptions.any(
      (option) => option.value == normalized,
    );
    return isSupported ? normalized : null;
  }
}

class PlotTypeOption {
  const PlotTypeOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
