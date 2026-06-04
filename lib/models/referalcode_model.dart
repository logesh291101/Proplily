class ReferalcodeModel {
  final bool status;
  final String message;
  final ReferralData? data;
  final dynamic errors;

  ReferalcodeModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ReferalcodeModel.fromJson(Map<String, dynamic> json) {
    return ReferalcodeModel(
      status: _parseStatus(json['status']),
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ReferralData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
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
}

class ReferralData {
  final String ownReferralCode;

  ReferralData({
    required this.ownReferralCode,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      ownReferralCode: json['own_referral_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'own_referral_code': ownReferralCode,
    };
  }
}
