class ClientFeedbackHistoryModel {
  final bool status;
  final String message;
  final List<FeedbackHistory> data;
  final dynamic errors;

  ClientFeedbackHistoryModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientFeedbackHistoryModel.fromJson(Map<String, dynamic> json) {
    return ClientFeedbackHistoryModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: parseFeedbackHistoryList(json['data']),
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
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      return t == '200' || t == 'true';
    }
    return false;
  }

  static List<FeedbackHistory> parseFeedbackHistoryList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => FeedbackHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map) {
      return [
        FeedbackHistory.fromJson(Map<String, dynamic>.from(raw)),
      ];
    }

    return [];
  }
}

class FeedbackHistory {
  final String feedbackId;
  final String userId;
  final String rating;
  final String feedbackMessage;
  final String createdAt;
  final String updatedAt;

  FeedbackHistory({
    required this.feedbackId,
    required this.userId,
    required this.rating,
    required this.feedbackMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeedbackHistory.fromJson(Map<String, dynamic> json) {
    return FeedbackHistory(
      feedbackId: json['feedback_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      rating: json['rating']?.toString() ?? '',
      feedbackMessage: json['feedback_message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedback_id': feedbackId,
      'user_id': userId,
      'rating': rating,
      'feedback_message': feedbackMessage,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
