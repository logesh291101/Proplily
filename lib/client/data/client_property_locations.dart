import 'dart:convert';

import 'package:country_state_city_picker/model/select_status_model.dart' as csc;
import 'package:flutter/services.dart';

/// Country / state / city lists loaded from [country_state_city_picker] assets.
class PropertyLocations {
  PropertyLocations._();

  static const _assetPath =
      'packages/country_state_city_picker/lib/assets/country.json';

  static List<csc.StatusModel>? _countries;
  static Future<void>? _loadFuture;

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _loadCountries();
  }

  static Future<void> _loadCountries() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      _countries = [];
      return;
    }

    _countries = decoded
        .whereType<Map>()
        .map((entry) => csc.StatusModel.fromJson(Map<String, dynamic>.from(entry)))
        .where((country) => country.name?.trim().isNotEmpty == true)
        .toList();
  }

  static void _assertLoaded() {
    if (_countries == null) {
      throw StateError(
        'PropertyLocations.ensureLoaded() must be called before reading data.',
      );
    }
  }

  static List<String> get countries {
    _assertLoaded();
    return _countries!
        .map((country) => country.name!.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static List<String> statesForCountry(String? country) {
    _assertLoaded();
    final countryModel = _findCountry(country);
    if (countryModel?.state == null) return const [];

    return countryModel!.state!
        .map((state) => state.name?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static List<String> citiesForState(String? country, String? state) {
    _assertLoaded();
    final countryModel = _findCountry(country);
    if (countryModel?.state == null) return const [];

    final stateModel = _findState(countryModel!.state!, state);
    if (stateModel?.city == null) return const [];

    return stateModel!.city!
        .map((city) => city.name?.trim() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Resolves a country name from a state when country is missing (edit flow).
  static String? countryForState(String? state) {
    _assertLoaded();
    final trimmedState = state?.trim();
    if (trimmedState == null || trimmedState.isEmpty) return null;

    for (final country in _countries!) {
      final states = country.state ?? const <csc.State>[];
      if (_findState(states, trimmedState) != null) {
        return country.name?.trim();
      }
    }
    return null;
  }

  /// Ensures a saved value from the API remains selectable when editing.
  static List<String> withSavedValue(List<String> options, String? saved) {
    final trimmed = saved?.trim();
    if (trimmed == null || trimmed.isEmpty || options.contains(trimmed)) {
      return options;
    }
    return [...options, trimmed];
  }

  static csc.StatusModel? _findCountry(String? country) {
    final trimmed = country?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    for (final model in _countries!) {
      final name = model.name?.trim();
      if (name != null && name.toLowerCase() == trimmed.toLowerCase()) {
        return model;
      }
    }
    return null;
  }

  static csc.State? _findState(List<csc.State> states, String? state) {
    final trimmed = state?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    for (final model in states) {
      final name = model.name?.trim();
      if (name != null && name.toLowerCase() == trimmed.toLowerCase()) {
        return model;
      }
    }
    return null;
  }
}
