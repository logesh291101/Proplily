import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the device maps app for a property location.
///
/// Uses the same flow as Client Home → My Properties → Open on Map:
/// launches Google Maps (or the default maps handler) at [latitude],[longitude].
abstract final class PropertyMapLauncher {
  /// Builds the external maps URI used across the app.
  static Uri? uriFromStrings({
    required String latitude,
    required String longitude,
  }) {
    final lat = latitude.trim();
    final lng = longitude.trim();
    if (lat.isEmpty || lng.isEmpty) return null;
    if (lat == '0' || lng == '0') return null;

    final latValue = double.tryParse(lat);
    final lngValue = double.tryParse(lng);
    if (latValue == null || lngValue == null) return null;
    if (latValue == 0 || lngValue == 0) return null;

    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  /// Returns true when [latitude] / [longitude] can be opened on a map.
  static bool hasCoordinates({
    required String latitude,
    required String longitude,
  }) {
    return uriFromStrings(latitude: latitude, longitude: longitude) != null;
  }

  /// Launches the installed maps app at the given coordinates.
  static Future<void> open(
    BuildContext context, {
    required String latitude,
    required String longitude,
  }) async {
    final uri = uriFromStrings(latitude: latitude, longitude: longitude);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open map.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
