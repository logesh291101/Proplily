// /// Static UI content for raise-ticket form (categories).
// class ClientSupportTicketContent {
//   ClientSupportTicketContent._();
//
//   static const List<String> ticketCategories = [
//     'Technical Issue',
//     'Property Related',
//     'Billing & Payments',
//     'Other Enquiry',
//   ];
// }
//
// /// A resolved support ticket in history UI.
// class ClientSupportTicketResolutionItem {
//   const ClientSupportTicketResolutionItem({
//     required this.status,
//     required this.date,
//     required this.subject,
//     required this.description,
//   });
//
//   final String status;
//   final String date;
//   final String subject;
//   final String description;
//
//   bool get isResolved => status.toLowerCase() == 'resolved';
// }
//
// class ClientSupportTicketModel {
//   final bool status;
//   final String message;
//   final List<ClientSupportTicket> data;
//   final dynamic errors;
//
//   ClientSupportTicketModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientSupportTicketModel.fromJson(Map<String, dynamic> json) {
//     return ClientSupportTicketModel(
//       status: json['status'] ?? false,
//       message: json['message'] ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .map((e) => ClientSupportTicket.fromJson(e))
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
// class ClientSupportTicket {
//   final String id;
//   final String userId;
//   final String subject;
//   final String category;
//   final String message;
//   final String status;
//   final String priority;
//   final String? adminReply;
//   final String? resolutionImage;
//   final String? lastRepliedAt;
//   final String createdAt;
//   final String updatedAt;
//   final String? resolutionMessage;
//   final String? reopenComment;
//   final String? forwardedBy;
//
//   ClientSupportTicket({
//     required this.id,
//     required this.userId,
//     required this.subject,
//     required this.category,
//     required this.message,
//     required this.status,
//     required this.priority,
//     this.adminReply,
//     this.resolutionImage,
//     this.lastRepliedAt,
//     required this.createdAt,
//     required this.updatedAt,
//     this.resolutionMessage,
//     this.reopenComment,
//     this.forwardedBy,
//   });
//
//   factory ClientSupportTicket.fromJson(Map<String, dynamic> json) {
//     return ClientSupportTicket(
//       id: json['id'] ?? '',
//       userId: json['user_id'] ?? '',
//       subject: json['subject'] ?? '',
//       category: json['category'] ?? '',
//       message: json['message'] ?? '',
//       status: json['status'] ?? '',
//       priority: json['priority'] ?? '',
//       adminReply: json['admin_reply'],
//       resolutionImage: json['resolution_image'],
//       lastRepliedAt: json['last_replied_at'],
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] ?? '',
//       resolutionMessage: json['resolution_message'],
//       reopenComment: json['reopen_comment'],
//       forwardedBy: json['forwarded_by'],
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

/// Static UI content for raise-ticket form (categories).
class ClientSupportTicketContent {
  ClientSupportTicketContent._();

  static const List<String> ticketCategories = [
    'Technical Issue',
    'Property Related',
    'Billing & Payments',
    'Other Enquiry',
  ];
}

/// A resolved support ticket in history UI.
class ClientSupportTicketResolutionItem {
  const ClientSupportTicketResolutionItem({
    required this.status,
    required this.date,
    required this.subject,
    required this.description,
  });

  final String status;
  final String date;
  final String subject;
  final String description;

  bool get isResolved => status.toLowerCase() == 'resolved';
}

class ClientSupportTicketModel {
  final bool status;
  final String message;
  final List<ClientSupportTicket> data;
  final dynamic errors;

  ClientSupportTicketModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientSupportTicketModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientSupportTicketModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientSupportTicketModel(
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

  static List<ClientSupportTicket> _parseTicketList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientSupportTicket.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientSupportTicket.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientSupportTicket {
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

  ClientSupportTicket({
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

  factory ClientSupportTicket.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientSupportTicket(
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

    return ClientSupportTicket(
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