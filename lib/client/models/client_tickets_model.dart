class ClientTicketsModel {
  final bool? status;
  final String? message;
  final List<ClientTicketData>? data;
  final dynamic errors;

  ClientTicketsModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory ClientTicketsModel.fromJson(Map<String, dynamic> json) {
    return ClientTicketsModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .whereType<Map>()
              .map((e) => ClientTicketData.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ClientTicketData>[],
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
}

class ClientTicketData {
  final String? id;
  final String? userId;
  final String? subject;
  final String? category;
  final String? message;
  final String? status;
  final String? priority;
  final String? adminReply;
  final String? resolutionImage;
  final String? lastRepliedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? resolutionMessage;
  final String? reopenComment;
  final String? forwardedBy;

  ClientTicketData({
    this.id,
    this.userId,
    this.subject,
    this.category,
    this.message,
    this.status,
    this.priority,
    this.adminReply,
    this.resolutionImage,
    this.lastRepliedAt,
    this.createdAt,
    this.updatedAt,
    this.resolutionMessage,
    this.reopenComment,
    this.forwardedBy,
  });

  factory ClientTicketData.fromJson(Map<String, dynamic> json) {
    return ClientTicketData(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      subject: json['subject'],
      category: json['category'],
      message: json['message'],
      status: json['status'],
      priority: json['priority'],
      adminReply: json['admin_reply'],
      resolutionImage: json['resolution_image'],
      lastRepliedAt: json['last_replied_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      resolutionMessage: json['resolution_message'],
      reopenComment: json['reopen_comment'],
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
