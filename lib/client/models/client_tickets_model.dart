// class ClientTicketsModel {
//   final bool? status;
//   final String? message;
//   final List<ClientTicketData>? data;
//   final dynamic errors;
//
//   ClientTicketsModel({
//     this.status,
//     this.message,
//     this.data,
//     this.errors,
//   });
//
//   factory ClientTicketsModel.fromJson(Map<String, dynamic> json) {
//     return ClientTicketsModel(
//       status: json['status'],
//       message: json['message'],
//       data: json['data'] != null
//           ? (json['data'] as List)
//               .whereType<Map>()
//               .map((e) => ClientTicketData.fromJson(Map<String, dynamic>.from(e)))
//               .toList()
//           : <ClientTicketData>[],
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
// }
//
// class ClientTicketData {
//   final String? id;
//   final String? userId;
//   final String? subject;
//   final String? category;
//   final String? message;
//   final String? status;
//   final String? priority;
//   final String? adminReply;
//   final String? resolutionImage;
//   final String? lastRepliedAt;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? resolutionMessage;
//   final String? reopenComment;
//   final String? forwardedBy;
//
//   ClientTicketData({
//     this.id,
//     this.userId,
//     this.subject,
//     this.category,
//     this.message,
//     this.status,
//     this.priority,
//     this.adminReply,
//     this.resolutionImage,
//     this.lastRepliedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.resolutionMessage,
//     this.reopenComment,
//     this.forwardedBy,
//   });
//
//   factory ClientTicketData.fromJson(Map<String, dynamic> json) {
//     return ClientTicketData(
//       id: json['id']?.toString(),
//       userId: json['user_id']?.toString(),
//       subject: json['subject'],
//       category: json['category'],
//       message: json['message'],
//       status: json['status'],
//       priority: json['priority'],
//       adminReply: json['admin_reply'],
//       resolutionImage: json['resolution_image'],
//       lastRepliedAt: json['last_replied_at'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       resolutionMessage: json['resolution_message'],
//       reopenComment: json['reopen_comment'],
//       forwardedBy: json['forwarded_by']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'user_id': userId,
//       'subject': subject,
//       'category': category,
//       'message': message,
//       'status': status,
//       'priority': priority,
//       'admin_reply': adminReply,
//       'resolution_image': resolutionImage,
//       'last_replied_at': lastRepliedAt,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'resolution_message': resolutionMessage,
//       'reopen_comment': reopenComment,
//       'forwarded_by': forwardedBy,
//     };
//   }
// }

class ClientTicketsModel {
  final bool status;
  final String message;
  final List<ClientTicketData> data;
  final dynamic errors;

  ClientTicketsModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientTicketsModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientTicketsModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientTicketsModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: _parseTicketList(json['data']),
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

  static List<ClientTicketData> _parseTicketList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientTicketData.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientTicketData.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientTicketData {
  final String id;
  final String userId;
  final String subject;
  final String category;
  final String message;
  final String status;
  final String priority;
  final String? adminReply;
  final String? resolutionImage;
  final String? lastRepliedAt;
  final String createdAt;
  final String updatedAt;
  final String? resolutionMessage;
  final String? reopenComment;
  final String? forwardedBy;

  ClientTicketData({
    required this.id,
    required this.userId,
    required this.subject,
    required this.category,
    required this.message,
    required this.status,
    required this.priority,
    this.adminReply,
    this.resolutionImage,
    this.lastRepliedAt,
    required this.createdAt,
    required this.updatedAt,
    this.resolutionMessage,
    this.reopenComment,
    this.forwardedBy,
  });

  factory ClientTicketData.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientTicketData(
        id: '',
        userId: '',
        subject: '',
        category: '',
        message: '',
        status: '',
        priority: '',
        adminReply: null,
        resolutionImage: null,
        lastRepliedAt: null,
        createdAt: '',
        updatedAt: '',
        resolutionMessage: null,
        reopenComment: null,
        forwardedBy: null,
      );
    }

    return ClientTicketData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      adminReply: json['admin_reply']?.toString(),
      resolutionImage: json['resolution_image']?.toString(),
      lastRepliedAt: json['last_replied_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      resolutionMessage: json['resolution_message']?.toString(),
      reopenComment: json['reopen_comment']?.toString(),
      forwardedBy: json['forwarded_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject': subject,
      'category': category,
      'message': message,
      'status': status,
      'priority': priority,
      'admin_reply': adminReply,
      'resolution_image': resolutionImage,
      'last_replied_at': lastRepliedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'resolution_message': resolutionMessage,
      'reopen_comment': reopenComment,
      'forwarded_by': forwardedBy,
    };
  }
}
