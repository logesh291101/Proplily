/// API response for `GET {live_url}/user/notifications`.
class ClientNotificationModel {
  ClientNotificationModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  final bool? status;
  final String? message;
  final List<NotificationData>? data;
  final dynamic errors;

  factory ClientNotificationModel.fromJson(Map<String, dynamic> json) {
    return ClientNotificationModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: _parseNotifications(json['data']),
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

  int get unreadCount => data?.where((n) => n.isUnread).length ?? 0;

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

  static List<NotificationData> _parseNotifications(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => NotificationData.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    return [];
  }
}

class NotificationData {
  NotificationData({
    this.notificationId,
    this.userId,
    this.contextClientId,
    this.title,
    this.message,
    this.image,
    this.redirectUrl,
    this.isRead,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  final String? notificationId;
  final String? userId;
  final String? contextClientId;
  final String? title;
  final String? message;
  final String? image;
  final String? redirectUrl;
  final String? isRead;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  bool get isUnread {
    final raw = isRead?.trim().toLowerCase() ?? '';
    if (raw.isEmpty) return true;
    return raw == '0' || raw == 'false' || raw == 'no';
  }

  String get displayTitle {
    final raw = title?.trim();
    return raw == null || raw.isEmpty ? '—' : raw;
  }

  String get displayMessage {
    final raw = message?.trim();
    return raw == null || raw.isEmpty ? '—' : raw;
  }

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notificationId: json['notification_id']?.toString(),
      userId: json['user_id']?.toString(),
      contextClientId: json['context_client_id']?.toString(),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      image: json['image']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      isRead: json['is_read']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'context_client_id': contextClientId,
      'title': title,
      'message': message,
      'image': image,
      'redirect_url': redirectUrl,
      'is_read': isRead,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}

String formatNotificationDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw.trim();

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final day = parsed.day.toString().padLeft(2, '0');
  final month = months[parsed.month - 1];
  final hour = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  final minute = parsed.minute.toString().padLeft(2, '0');
  final period = parsed.hour >= 12 ? 'PM' : 'AM';

  return '$day $month ${parsed.year} $hour:$minute $period';
}
