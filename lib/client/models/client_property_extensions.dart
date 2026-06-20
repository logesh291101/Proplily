import 'dart:convert';

import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/models/client_property_status_model.dart';

extension ClientPropertyUi on ClientProperty {
  String get photoUrl => _resolvePhotoUrl(propertyPhoto);

  String get displayStatus {
    final monitoring = _trim(monitoringStatus);
    if (monitoring.isNotEmpty) return monitoring;
    final authorization = _trim(authorizationStatus);
    if (authorization.isNotEmpty) return authorization;
    return '—';
  }

  String get displayLocation {
    final cityText = _trim(city);
    final stateText = _trim(state);
    if (cityText.isNotEmpty && stateText.isNotEmpty) {
      return '$cityText, $stateText';
    }
    if (cityText.isNotEmpty) return cityText;
    if (stateText.isNotEmpty) return stateText;
    final addressText = _trim(address);
    return addressText.isNotEmpty ? addressText : '—';
  }

  String get displayArea {
    final size = _trim(plotSize);
    if (size.isEmpty) return '—';
    final unit = _trim(sizeUnit);
    return unit.isNotEmpty ? '$size $unit' : size;
  }

  String get displayPlotType {
    final plot = _trim(plotType);
    if (plot.isNotEmpty) return plot;
    final type = _trim(propertyType);
    return type.isNotEmpty ? type : '—';
  }

  bool get hasMapCoordinates {
    final lat = _trim(latitude);
    final lng = _trim(longitude);
    if (lat.isEmpty || lng.isEmpty) return false;
    return double.tryParse(lat) != null && double.tryParse(lng) != null;
  }

  String get verifiedDaysAgoLabel {
    final date = _parseDate(verifiedAt) ?? _parseDate(updatedAt);
    if (date == null) return 'Last verified: —';
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'Last verified: today';
    if (days == 1) return 'Last verified: 1 day ago';
    return 'Last verified: $days days ago';
  }

  String get formattedUpdatedAt {
    final date = _parseDate(updatedAt);
    if (date == null) return '—';
    return _formatDate(date);
  }

  ClientPropertyStatusItem toEditPropertyItem() {
    return ClientPropertyStatusItem(
      propertyId: _trim(propertyId),
      propertyName: _trim(propertyName),
      propertyType: _trim(plotType).isNotEmpty
          ? _trim(plotType)
          : _trim(propertyType),
      address: _trim(address),
      city: _trim(city),
      country: '',
      state: _trim(state),
      plotSize: _trim(plotSize),
      latitude: _trim(latitude),
      longitude: _trim(longitude),
      ownerName: '',
      ownerPhone: '',
      monitoringStatus: _trim(monitoringStatus),
      authorizationStatus: _trim(authorizationStatus),
      createdAt: _trim(createdAt),
    );
  }

  static String _trim(String? value) => value?.trim() ?? '';

  static String _resolvePhotoUrl(String? raw) {
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is String && first.trim().isNotEmpty) {
            return first.trim();
          }
          if (first is Map) {
            final url = first['url'] ?? first['image'] ?? first['path'];
            if (url is String && url.trim().isNotEmpty) {
              return url.trim();
            }
          }
        }
      } catch (_) {
        return trimmed;
      }
    }

    return trimmed;
  }

  static DateTime? _parseDate(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
