// class ClientReferralListModel {
//   final bool status;
//   final String message;
//   final ClientReferralData data;
//   final dynamic errors;
//
//   ClientReferralListModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientReferralListModel.fromJson(Map<String, dynamic> json) {
//     return ClientReferralListModel(
//       status: json['status'] ?? false,
//       message: json['message']?.toString() ?? '',
//       data: ClientReferralData.fromJson(
//         _mapFromDynamic(json['data']) ?? const {},
//       ),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.toJson(),
//       'errors': errors,
//     };
//   }
//
//   static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
//     if (raw is Map<String, dynamic>) return raw;
//     if (raw is Map) return Map<String, dynamic>.from(raw);
//     return null;
//   }
// }
//
// class ClientReferralData {
//   final String myReferralCode;
//   final List<ClientReferral> referrals;
//
//   ClientReferralData({
//     required this.myReferralCode,
//     required this.referrals,
//   });
//
//   factory ClientReferralData.fromJson(Map<String, dynamic> json) {
//     return ClientReferralData(
//       myReferralCode: json['my_referral_code']?.toString() ?? '',
//       referrals: (json['referrals'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientReferral.fromJson(Map<String, dynamic>.from(e)),
//           )
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'my_referral_code': myReferralCode,
//       'referrals': referrals.map((e) => e.toJson()).toList(),
//     };
//   }
// }
//
// class ClientReferral {
//   final String referredId;
//   final String referredName;
//   final String referredEmail;
//   final String joinedAt;
//   final String referrerId;
//   final String referrerName;
//   final String referrerEmail;
//   final String statusLabel;
//
//   ClientReferral({
//     required this.referredId,
//     required this.referredName,
//     required this.referredEmail,
//     required this.joinedAt,
//     required this.referrerId,
//     required this.referrerName,
//     required this.referrerEmail,
//     required this.statusLabel,
//   });
//
//   factory ClientReferral.fromJson(Map<String, dynamic> json) {
//     return ClientReferral(
//       referredId: json['referred_id']?.toString() ?? '',
//       referredName: json['referred_name']?.toString() ?? '',
//       referredEmail: json['referred_email']?.toString() ?? '',
//       joinedAt: json['joined_at']?.toString() ?? '',
//       referrerId: json['referrer_id']?.toString() ?? '',
//       referrerName: json['referrer_name']?.toString() ?? '',
//       referrerEmail: json['referrer_email']?.toString() ?? '',
//       statusLabel: json['status_label']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'referred_id': referredId,
//       'referred_name': referredName,
//       'referred_email': referredEmail,
//       'joined_at': joinedAt,
//       'referrer_id': referrerId,
//       'referrer_name': referrerName,
//       'referrer_email': referrerEmail,
//       'status_label': statusLabel,
//     };
//   }
// }

class ClientReferralListModel {
  final bool status;
  final String message;
  final ClientReferralData data;
  final dynamic errors;

  ClientReferralListModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientReferralListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientReferralListModel(
        status: false,
        message: '',
        data: ClientReferralData.fromJson(null),
        errors: null,
      );
    }

    return ClientReferralListModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: ClientReferralData.fromJson(
        _mapFromDynamic(json['data']),
      ),
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

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}

class ClientReferralData {
  final String myReferralCode;
  final List<ClientReferral> referrals;

  ClientReferralData({
    required this.myReferralCode,
    required this.referrals,
  });

  factory ClientReferralData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientReferralData(
        myReferralCode: '',
        referrals: const [],
      );
    }

    return ClientReferralData(
      myReferralCode: json['my_referral_code']?.toString() ?? '',
      referrals: _parseReferralList(json['referrals']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'my_referral_code': myReferralCode,
      'referrals': referrals.map((e) => e.toJson()).toList(),
    };
  }

  static List<ClientReferral> _parseReferralList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientReferral.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientReferral.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientReferral {
  final String referredId;
  final String referredName;
  final String referredEmail;
  final String joinedAt;
  final String referrerId;
  final String referrerName;
  final String referrerEmail;
  final String statusLabel;

  ClientReferral({
    required this.referredId,
    required this.referredName,
    required this.referredEmail,
    required this.joinedAt,
    required this.referrerId,
    required this.referrerName,
    required this.referrerEmail,
    required this.statusLabel,
  });

  factory ClientReferral.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientReferral(
        referredId: '',
        referredName: '',
        referredEmail: '',
        joinedAt: '',
        referrerId: '',
        referrerName: '',
        referrerEmail: '',
        statusLabel: '',
      );
    }

    return ClientReferral(
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