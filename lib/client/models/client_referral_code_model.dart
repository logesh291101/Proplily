// class ReferalcodeModel {
//   final bool status;
//   final String message;
//   final ReferralData? data;
//   final dynamic errors;
//
//   ReferalcodeModel({
//     required this.status,
//     required this.message,
//     this.data,
//     this.errors,
//   });
//
//   factory ReferalcodeModel.fromJson(Map<String, dynamic> json) {
//     return ReferalcodeModel(
//       status: _parseStatus(json['status']),
//       message: json['message'] ?? '',
//       data: json['data'] != null
//           ? ReferralData.fromJson(json['data'] as Map<String, dynamic>)
//           : null,
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data?.toJson(),
//       'errors': errors,
//     };
//   }
//
//   static bool _parseStatus(dynamic raw) {
//     if (raw is bool) return raw;
//     if (raw is int) return raw == 200;
//     if (raw is num) return raw == 200;
//     if (raw is String) {
//       final t = raw.trim().toLowerCase();
//       return t == '200' || t == 'true';
//     }
//     return false;
//   }
// }
//
// class ReferralData {
//   final String ownReferralCode;
//
//   ReferralData({
//     required this.ownReferralCode,
//   });
//
//   factory ReferralData.fromJson(Map<String, dynamic> json) {
//     return ReferralData(
//       ownReferralCode: json['own_referral_code'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'own_referral_code': ownReferralCode,
//     };
//   }
// }

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

  factory ReferalcodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReferalcodeModel(
        status: false,
        message: '',
        data: null,
        errors: null,
      );
    }

    return ReferalcodeModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? ReferralData.fromJson(
        Map<String, dynamic>.from(json['data']),
      )
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
}

class ReferralData {
  final String ownReferralCode;

  const ReferralData({
    required this.ownReferralCode,
  });

  factory ReferralData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ReferralData(
        ownReferralCode: '',
      );
    }

    return ReferralData(
      ownReferralCode:
      json['own_referral_code']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'own_referral_code': ownReferralCode,
    };
  }
}