import 'dart:convert';

import 'package:proplilly/client/models/client_properties_detail_model.dart';
import 'package:proplilly/client/models/client_properties_list_model.dart';

extension ClientPropertyListUi on ClientProperty {
  String get photoUrl {
    final photo = propertyPhoto?.trim();
    if (photo == null || photo.isEmpty) return '';

    final urls = ClientPropertyMediaParser.parseUrls(photo);
    return urls.isNotEmpty ? urls.first : photo;
  }

  String displayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty ? trimmed : '—';
  }

  String get displayStatus {
    final monitoring = monitoringStatus.trim();
    if (monitoring.isNotEmpty) return monitoring;
    final authorization = authorizationStatus?.trim() ?? '';
    if (authorization.isNotEmpty) return authorization;
    return '—';
  }

  String get displayLocation {
    final cityText = city.trim();
    final stateText = state.trim();
    if (cityText.isNotEmpty && stateText.isNotEmpty) {
      return '$cityText, $stateText';
    }
    if (cityText.isNotEmpty) return cityText;
    if (stateText.isNotEmpty) return stateText;
    final addressText = address.trim();
    return addressText.isNotEmpty ? addressText : '—';
  }

  String get displayArea {
    final size = plotSize.trim();
    if (size.isEmpty) return '—';
    final unit = sizeUnit.trim();
    return unit.isNotEmpty ? '$size $unit' : size;
  }

  String get displayPlotType {
    final plot = plotType.trim();
    if (plot.isNotEmpty) return plot;
    final type = propertyType.trim();
    return type.isNotEmpty ? type : '—';
  }

  bool get hasMapCoordinates {
    final lat = latitude.trim();
    final lng = longitude.trim();
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

extension ClientPropertyDetailDataUi on ClientPropertyDetailData {
  ClientPropertyDetail get details => property;

  List<String> get imageUrls {
    final primaryFirst = [...images]
      ..sort((a, b) {
        final aPrimary =
            a.isPrimary.trim() == '1' || a.isPrimary.toLowerCase() == 'true';
        final bPrimary =
            b.isPrimary.trim() == '1' || b.isPrimary.toLowerCase() == 'true';
        if (aPrimary == bPrimary) return 0;
        return aPrimary ? -1 : 1;
      });

    final paths = primaryFirst
        .map((image) => image.imagePath.trim())
        .where((path) => path.isNotEmpty)
        .toList();

    if (paths.isNotEmpty) return paths;

    return ClientPropertyMediaParser.parseUrls(property.propertyPhoto);
  }

  List<String> get documentUrls =>
      ClientPropertyMediaParser.parseUrls(property.plotDocuments);

  String displayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty ? trimmed : '—';
  }

  String get displayStatus {
    final monitoring = property.monitoringStatus.trim();
    if (monitoring.isNotEmpty) return monitoring;
    final authorization = property.authorizationStatus?.trim() ?? '';
    if (authorization.isNotEmpty) return authorization;
    return '—';
  }

  String get displayPlotType {
    final plot = property.plotType.trim();
    if (plot.isNotEmpty) return plot;
    final type = property.propertyType.trim();
    return type.isNotEmpty ? type : '—';
  }

  String get displayArea {
    final size = property.plotSize.trim();
    if (size.isEmpty) return '—';
    final unit = property.sizeUnit.trim();
    return unit.isNotEmpty ? '$size $unit' : size;
  }
}

class ClientPropertyMediaParser {
  ClientPropertyMediaParser._();

  static List<String> parseUrls(String? raw) {
    if (raw == null) return [];

    final urls = <String>[];

    void addUrl(String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty && !urls.contains(trimmed)) {
        urls.add(trimmed);
      }
    }

    try {
      if (raw.trim().startsWith('[')) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              addUrl(
                item['url']?.toString() ??
                    item['image']?.toString() ??
                    item['path']?.toString() ??
                    item['image_path']?.toString() ??
                    item['name']?.toString(),
              );
            } else {
              addUrl(item?.toString());
            }
          }
        }
      } else if (raw.contains(',')) {
        for (final part in raw.split(',')) {
          addUrl(part);
        }
      } else {
        addUrl(raw);
      }
    } catch (_) {
      addUrl(raw);
    }

    return urls;
  }
}
