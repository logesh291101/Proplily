// class ClientMarketLinesModel {
//   final bool status;
//   final String message;
//   final List<ClientMarketHeadline> data;
//   final dynamic errors;
//
//   ClientMarketLinesModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientMarketLinesModel.fromJson(Map<String, dynamic> json) {
//     return ClientMarketLinesModel(
//       status: json['status'] ?? false,
//       message: json['message'] ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientMarketHeadline.fromJson(
//               Map<String, dynamic>.from(e),
//             ),
//           )
//           .toList(),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.map((e) => e.toJson()).toList(),
//       'errors': errors,
//     };
//   }
// }
//
// class ClientMarketHeadline {
//   final String id;
//   final String category;
//   final String title;
//   final String authorName;
//   final String authorLogo;
//   final String smallImage;
//   final String largeImage;
//   final String shortDescription;
//   final String fullDescription;
//   final String createdAt;
//   final String updatedAt;
//
//   ClientMarketHeadline({
//     required this.id,
//     required this.category,
//     required this.title,
//     required this.authorName,
//     required this.authorLogo,
//     required this.smallImage,
//     required this.largeImage,
//     required this.shortDescription,
//     required this.fullDescription,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory ClientMarketHeadline.fromJson(Map<String, dynamic> json) {
//     return ClientMarketHeadline(
//       id: json['id']?.toString() ?? '',
//       category: json['category'] ?? '',
//       title: json['title'] ?? '',
//       authorName: json['author_name'] ?? '',
//       authorLogo: json['author_logo'] ?? '',
//       smallImage: json['small_image'] ?? '',
//       largeImage: json['large_image'] ?? '',
//       shortDescription: json['short_description'] ?? '',
//       fullDescription: json['full_description'] ?? '',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'category': category,
//       'title': title,
//       'author_name': authorName,
//       'author_logo': authorLogo,
//       'small_image': smallImage,
//       'large_image': largeImage,
//       'short_description': shortDescription,
//       'full_description': fullDescription,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//     };
//   }
// }

class ClientMarketLinesModel {
  final bool status;
  final String message;
  final List<ClientMarketHeadline> data;
  final dynamic errors;

  ClientMarketLinesModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientMarketLinesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientMarketLinesModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientMarketLinesModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: parseHeadlineList(json['data']),
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

  static bool _parseStatus(dynamic raw) {
    if (raw == null) return false;

    if (raw is bool) return raw;

    if (raw is num) {
      return raw == 1 || raw == 200;
    }

    if (raw is String) {
      final value = raw.trim().toLowerCase();

      return value == 'true' ||
          value == '1' ||
          value == '200' ||
          value == 'success';
    }

    return false;
  }

  static List<ClientMarketHeadline> parseHeadlineList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientMarketHeadline.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientMarketHeadline.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientMarketHeadline {
  final String id;
  final String category;
  final String title;
  final String authorName;
  final String authorLogo;
  final String smallImage;
  final String largeImage;
  final String shortDescription;
  final String fullDescription;
  final String createdAt;
  final String updatedAt;

  ClientMarketHeadline({
    required this.id,
    required this.category,
    required this.title,
    required this.authorName,
    required this.authorLogo,
    required this.smallImage,
    required this.largeImage,
    required this.shortDescription,
    required this.fullDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientMarketHeadline.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientMarketHeadline(
        id: '',
        category: '',
        title: '',
        authorName: '',
        authorLogo: '',
        smallImage: '',
        largeImage: '',
        shortDescription: '',
        fullDescription: '',
        createdAt: '',
        updatedAt: '',
      );
    }

    return ClientMarketHeadline(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? '',
      authorLogo: json['author_logo']?.toString() ?? '',
      smallImage: json['small_image']?.toString() ?? '',
      largeImage: json['large_image']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      fullDescription: json['full_description']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'author_name': authorName,
      'author_logo': authorLogo,
      'small_image': smallImage,
      'large_image': largeImage,
      'short_description': shortDescription,
      'full_description': fullDescription,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}