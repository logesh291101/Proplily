/// API response for `POST {live_url}/coordinator_api/tasks/{task_id}/report`.
class FieldAgentSubmitReportModel {
  FieldAgentSubmitReportModel({
    this.status,
    this.message,
    this.errors,
  });

  final bool? status;
  final String? message;
  final dynamic errors;

  factory FieldAgentSubmitReportModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentSubmitReportModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
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
}
