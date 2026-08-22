// import 'dart:convert';
//
// /// API response for `GET {live_url}/user/ads`.
// class ClientAdsModel {
//   ClientAdsModel({
//     this.status,
//     this.message,
//     this.data,
//     this.errors,
//   });
//
//   final bool? status;
//   final String? message;
//   final List<ClientAdData>? data;
//   final dynamic errors;
//
//   factory ClientAdsModel.fromJson(Map<String, dynamic> json) {
//     return ClientAdsModel(
//       status: _parseStatus(json['status']),
//       message: json['message']?.toString(),
//       data: _parseAds(json['data']),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data?.map((e) => e.toJson()).toList(),
//       'errors': errors,
//     };
//   }
//
//   bool get isSuccess => status == true;
//
//   static bool? _parseStatus(dynamic raw) {
//     if (raw == null) return null;
//     if (raw is bool) return raw;
//     if (raw is int) return raw == 200;
//     if (raw is num) return raw == 200;
//     if (raw is String) {
//       final t = raw.trim().toLowerCase();
//       if (t == '200' || t == 'true') return true;
//       if (t == 'false') return false;
//     }
//     return null;
//   }
//
//   static List<ClientAdData>? _parseAds(dynamic raw) {
//     if (raw == null) return null;
//     if (raw is! List) return null;
//
//     return raw
//         .whereType<Map>()
//         .map((e) => ClientAdData.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }
// }
//
// class ClientAdData {
//   ClientAdData({
//     this.id,
//     this.title,
//     this.content,
//     this.ctaText,
//     List<String>? adImages,
//   }) : adImages = adImages ?? const [];
//
//   final String? id;
//   final String? title;
//   final String? content;
//   final String? ctaText;
//   final List<String> adImages;
//
//   factory ClientAdData.fromJson(Map<String, dynamic> json) {
//     return ClientAdData(
//       id: _stringOrNull(json['id'] ?? json['ad_id']),
//       title: _stringOrNull(json['title']),
//       content: _stringOrNull(json['content']),
//       ctaText: _stringOrNull(json['cta_text']),
//       adImages: _parseAdImages(json['ad_images']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'content': content,
//       'cta_text': ctaText,
//       'ad_images': adImages,
//     };
//   }
//
//   String? get bannerImageUrl {
//     if (adImages.isEmpty) return null;
//     return adImages.first;
//   }
//
//   static String? _stringOrNull(dynamic raw) {
//     if (raw == null) return null;
//     if (raw is String) return raw.isEmpty ? null : raw;
//     return raw.toString();
//   }
//
//   static List<String> _parseAdImages(dynamic raw) {
//     if (raw == null) return const [];
//
//     if (raw is List) {
//       final urls = <String>[];
//       for (final item in raw) {
//         if (item is Map) {
//           final url = _stringOrNull(item['url']) ?? _stringOrNull(item['image']);
//           if (url != null) urls.add(url);
//         } else {
//           final url = _stringOrNull(item);
//           if (url != null) urls.add(url);
//         }
//       }
//       return urls;
//     }
//
//     if (raw is String && raw.trim().isNotEmpty) {
//       final trimmed = raw.trim();
//       if (trimmed.startsWith('[')) {
//         try {
//           final decoded = jsonDecode(trimmed);
//           if (decoded is List) {
//             return _parseAdImages(decoded);
//           }
//         } catch (_) {}
//       }
//       if (trimmed.contains(',')) {
//         return trimmed
//             .split(',')
//             .map((part) => part.trim())
//             .where((part) => part.isNotEmpty)
//             .toList();
//       }
//       return [trimmed];
//     }
//
//     return const [];
//   }
// }

import 'dart:convert';

/// API response for GET {live_url}/user/ads.
class ClientAdsModel {
  final bool status;
  final String message;
  final List<ClientAdData> data;
  final dynamic errors;

  ClientAdsModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientAdsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAdsModel(
        status: false,
        message: '',
        data: [],
        errors: null,
      );
    }

    return ClientAdsModel(
      status: _parseStatus(json['status']) ?? false,
      message: json['message']?.toString() ?? '',
      data: _parseAds(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }

  bool get isSuccess => status;

  static bool? _parseStatus(dynamic raw) {
    if (raw == null) return null;

    if (raw is bool) return raw;

    if (raw is num) {
      return raw == 1 || raw == 200;
    }

    if (raw is String) {
      final value = raw.trim().toLowerCase();

      if (value == 'true' ||
          value == '1' ||
          value == '200' ||
          value == 'success') {
        return true;
      }

      if (value == 'false' || value == '0') {
        return false;
      }
    }

    return null;
  }

  static List<ClientAdData> _parseAds(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => ClientAdData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map) {
      return [
        ClientAdData.fromJson(Map<String, dynamic>.from(raw)),
      ];
    }

    return [];
  }
}

class ClientAdData {
  final String id;
  final String title;
  final String content;
  final String ctaText;
  final List<String> adImages;

  ClientAdData({
    required this.id,
    required this.title,
    required this.content,
    required this.ctaText,
    required this.adImages,
  });

  factory ClientAdData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAdData(
        id: '',
        title: '',
        content: '',
        ctaText: '',
        adImages: const [],
      );
    }

    return ClientAdData(
      id: _string(json['id'] ?? json['ad_id']),
      title: _string(json['title']),
      content: _string(json['content']),
      ctaText: _string(json['cta_text']),
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

  String? get bannerImageUrl =>
      adImages.isNotEmpty ? adImages.first : null;

  static String _string(dynamic value) {
    return value?.toString() ?? '';
  }

  static List<String> _parseAdImages(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map((item) {
        if (item is Map) {
          return _string(item['url'].toString().isNotEmpty
              ? item['url']
              : item['image']);
        }
        return _string(item);
      })
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (raw is String) {
      final trimmed = raw.trim();

      if (trimmed.isEmpty) return [];

      if (trimmed.startsWith('[')) {
        try {
          final decoded = jsonDecode(trimmed);
          return _parseAdImages(decoded);
        } catch (_) {}
      }

      if (trimmed.contains(',')) {
        return trimmed
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      return [trimmed];
    }

    return [];
  }
}