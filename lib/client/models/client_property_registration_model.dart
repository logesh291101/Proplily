/// API response for property registration (`POST /user/properties/store`).
class ClientPropertyRegistrationModel {
  ClientPropertyRegistrationModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  final bool? status;
  final String? message;
  final dynamic data;
  final dynamic errors;

  factory ClientPropertyRegistrationModel.fromJson(Map<String, dynamic> json) {
    return ClientPropertyRegistrationModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: json['data'],
      errors: json['errors'],
    );
  }

  bool get isSuccess => status == true;

  static bool? _parseStatus(dynamic raw) {
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
