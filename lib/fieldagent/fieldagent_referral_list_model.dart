class FieldAgentReferralListModel {
  final bool status;
  final String message;
  final FieldAgentReferralData data;
  final dynamic errors;

  FieldAgentReferralListModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory FieldAgentReferralListModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentReferralListModel(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: _parseData(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
      'errors': errors,
    };
  }

  static FieldAgentReferralData _parseData(dynamic raw) {
    if (raw is List) {
      return FieldAgentReferralData(myReferralCode: '', referrals: const []);
    }

    final map = _mapFromDynamic(raw);
    if (map == null) {
      return FieldAgentReferralData(myReferralCode: '', referrals: const []);
    }

    return FieldAgentReferralData.fromJson(map);
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}

class FieldAgentReferralData {
  final String myReferralCode;
  final List<FieldAgentReferral> referrals;

  FieldAgentReferralData({
    required this.myReferralCode,
    required this.referrals,
  });

  factory FieldAgentReferralData.fromJson(Map<String, dynamic> json) {
    return FieldAgentReferralData(
      myReferralCode: json['my_referral_code']?.toString() ?? '',
      referrals: (json['referrals'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map(
            (e) => FieldAgentReferral.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'my_referral_code': myReferralCode,
      'referrals': referrals.map((e) => e.toJson()).toList(),
    };
  }
}

class FieldAgentReferral {
  final String referredId;
  final String referredName;
  final String referredEmail;
  final String joinedAt;
  final String referrerId;
  final String referrerName;
  final String referrerEmail;
  final String statusLabel;

  FieldAgentReferral({
    required this.referredId,
    required this.referredName,
    required this.referredEmail,
    required this.joinedAt,
    required this.referrerId,
    required this.referrerName,
    required this.referrerEmail,
    required this.statusLabel,
  });

  factory FieldAgentReferral.fromJson(Map<String, dynamic> json) {
    return FieldAgentReferral(
      referredId: json['referred_id']?.toString() ?? '',
      referredName: json['referred_name']?.toString() ?? '',
      referredEmail: json['referred_email']?.toString() ?? '',
      joinedAt: json['joined_at']?.toString() ?? '',
      referrerId: json['referrer_id']?.toString() ?? '',
      referrerName: json['referrer_name']?.toString() ?? '',
      referrerEmail: json['referrer_email']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referred_id': referredId,
      'referred_name': referredName,
      'referred_email': referredEmail,
      'joined_at': joinedAt,
      'referrer_id': referrerId,
      'referrer_name': referrerName,
      'referrer_email': referrerEmail,
      'status_label': statusLabel,
    };
  }
}
