import 'dart:convert';

/// API response for `GET {live_url}/coordinator_api/ads`.
class FieldAgentAdsModel {
  FieldAgentAdsModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  final bool? status;
  final String? message;
  final List<FieldAgentAdData>? data;
  final dynamic errors;

  factory FieldAgentAdsModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentAdsModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: _parseAds(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }

  bool get isSuccess => status == true;

  static bool? _parseStatus(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      if (t == '200' || t == 'true') return true;
      if (t == 'false') return false;
    }
    return null;
  }

  static List<FieldAgentAdData>? _parseAds(dynamic raw) {
    if (raw == null) return null;
    if (raw is! List) return null;

    final ads = raw
        .whereType<Map>()
        .map((e) => FieldAgentAdData.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ads;
  }
}

class FieldAgentAdData {
  FieldAgentAdData({
    this.id,
    this.title,
    this.content,
    this.ctaText,
    List<String>? adImages,
  }) : adImages = adImages ?? const [];

  final String? id;
  final String? title;
  final String? content;
  final String? ctaText;
  final List<String> adImages;

  factory FieldAgentAdData.fromJson(Map<String, dynamic> json) {
    return FieldAgentAdData(
      id: _stringOrNull(json['id'] ?? json['ad_id']),
      title: _stringOrNull(json['title']),
      content: _stringOrNull(json['content']),
      ctaText: _stringOrNull(json['cta_text']),
      adImages: _parseAdImages(json['ad_images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'cta_text': ctaText,
      'ad_images': adImages,
    };
  }

  String? get bannerImageUrl {
    if (adImages.isEmpty) return null;
    return adImages.first;
  }

  static String? _stringOrNull(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    return raw.toString();
  }

  static List<String> _parseAdImages(dynamic raw) {
    if (raw == null) return const [];

    if (raw is List) {
      final urls = <String>[];
      for (final item in raw) {
        if (item is Map) {
          final url = _stringOrNull(item['url']) ?? _stringOrNull(item['image']);
          if (url != null) urls.add(url);
        } else {
          final url = _stringOrNull(item);
          if (url != null) urls.add(url);
        }
      }
      return urls;
    }

    if (raw is String && raw.trim().isNotEmpty) {
      final trimmed = raw.trim();
      if (trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is List) {
            return _parseAdImages(decoded);
          }
        } catch (_) {}
      }
      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toList();
      }
      return [trimmed];
    }

    return const [];
  }
}
