/// API response for `GET {live_url}/user/support/tickets`.
class ClientTicketsModel {
  ClientTicketsModel({
    required this.status,
    required this.message,
    required this.tickets,
    this.errors,
  });

  final bool status;
  final String message;
  final List<ClientTicket> tickets;
  final dynamic errors;

  factory ClientTicketsModel.fromJson(Map<String, dynamic> json) {
    return ClientTicketsModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      tickets: _parseTickets(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': tickets.map((t) => t.toJson()).toList(),
      'errors': errors,
    };
  }

  static bool _parseStatus(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      return t == '200' || t == 'true';
    }
    return false;
  }

  static List<ClientTicket> _parseTickets(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => ClientTicket.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['tickets', 'items', 'list']) {
        if (map[key] != null) {
          return _parseTickets(map[key]);
        }
      }
    }

    return [];
  }
}

/// Single support ticket from [ClientTicketsModel.tickets].
class ClientTicket {
  ClientTicket({
    required this.id,
    this.subject,
    this.category,
    this.message,
    this.priority,
    this.adminReply,
    this.lastRepliedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? subject;
  final String? category;
  final String? message;
  final String? priority;
  final String? adminReply;
  final String? lastRepliedAt;
  final String? createdAt;
  final String? updatedAt;

  factory ClientTicket.fromJson(Map<String, dynamic> json) {
    return ClientTicket(
      id: json['id']?.toString() ?? '',
      subject: _nullableString(json['subject']),
      category: _nullableString(json['category']),
      message: _nullableString(json['message']),
      priority: _nullableString(json['priority']),
      adminReply: _nullableString(json['admin_reply']),
      lastRepliedAt: _nullableString(json['last_replied_at']),
      createdAt: _nullableString(json['created_at']),
      updatedAt: _nullableString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'category': category,
      'message': message,
      'priority': priority,
      'admin_reply': adminReply,
      'last_replied_at': lastRepliedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }
}
