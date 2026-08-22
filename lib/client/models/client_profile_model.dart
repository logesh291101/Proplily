// class ClientProfileModel {
//   final bool status;
//   final String message;
//   final ClientData? data;
//   final dynamic errors;
//
//   ClientProfileModel({
//     required this.status,
//     required this.message,
//     this.data,
//     this.errors,
//   });
//
//   factory ClientProfileModel.fromJson(Map<String, dynamic> json) {
//     return ClientProfileModel(
//       status: json['status'] ?? false,
//       message: json['message'] ?? '',
//       data: json['data'] != null
//           ? ClientData.fromJson(json['data'] as Map<String, dynamic>)
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
// }
//
// class ClientData {
//   final String userId;
//   final String name;
//   final String email;
//   final String phone;
//   final String countryCode;
//   final String passwordHistory;
//   final String passwordResetFlag;
//   final String role;
//   final String accountManagerId;
//   final String? profileImage;
//   final String lastLogin;
//   final String lastIp;
//   final String? resetToken;
//   final String? tokenExpiresAt;
//   final String status;
//   final String createdAt;
//   final String? updatedAt;
//   final String? deletedAt;
//   final String? deleteScheduledAt;
//   final String ownReferralCode;
//   final String? referredByUserId;
//   final String? referredAt;
//
//   ClientData({
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.countryCode,
//     required this.passwordHistory,
//     required this.passwordResetFlag,
//     required this.role,
//     required this.accountManagerId,
//     this.profileImage,
//     required this.lastLogin,
//     required this.lastIp,
//     this.resetToken,
//     this.tokenExpiresAt,
//     required this.status,
//     required this.createdAt,
//     this.updatedAt,
//     this.deletedAt,
//     this.deleteScheduledAt,
//     required this.ownReferralCode,
//     this.referredByUserId,
//     this.referredAt,
//   });
//
//   factory ClientData.fromJson(Map<String, dynamic> json) {
//     return ClientData(
//       userId: json['user_id']?.toString() ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       countryCode: json['country_code'] ?? '',
//       passwordHistory: json['password_history'] ?? '',
//       passwordResetFlag: json['password_reset_flag'] ?? '',
//       role: json['role'] ?? '',
//       accountManagerId: json['account_manager_id']?.toString() ?? '',
//       profileImage: json['profile_image'] as String?,
//       lastLogin: json['last_login'] ?? '',
//       lastIp: json['last_ip'] ?? '',
//       resetToken: json['reset_token'] as String?,
//       tokenExpiresAt: json['token_expires_at'] as String?,
//       status: json['status']?.toString() ?? '',
//       createdAt: json['created_at'] ?? '',
//       updatedAt: json['updated_at'] as String?,
//       deletedAt: json['deleted_at'] as String?,
//       deleteScheduledAt: json['delete_scheduled_at'] as String?,
//       ownReferralCode: json['own_referral_code'] ?? '',
//       referredByUserId: json['referred_by_user_id']?.toString(),
//       referredAt: json['referred_at'] as String?,
//     );
//   }
//
//   /// True when the profile API indicates account deletion is scheduled.
//   bool get isDeletionScheduled {
//     final scheduledAt = deleteScheduledAt?.trim();
//     if (scheduledAt != null && scheduledAt.isNotEmpty) return true;
//
//     final deleted = deletedAt?.trim();
//     if (deleted != null && deleted.isNotEmpty) return true;
//
//     return false;
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'name': name,
//       'email': email,
//       'phone': phone,
//       'country_code': countryCode,
//       'password_history': passwordHistory,
//       'password_reset_flag': passwordResetFlag,
//       'role': role,
//       'account_manager_id': accountManagerId,
//       'profile_image': profileImage,
//       'last_login': lastLogin,
//       'last_ip': lastIp,
//       'reset_token': resetToken,
//       'token_expires_at': tokenExpiresAt,
//       'status': status,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'deleted_at': deletedAt,
//       'delete_scheduled_at': deleteScheduledAt,
//       'own_referral_code': ownReferralCode,
//       'referred_by_user_id': referredByUserId,
//       'referred_at': referredAt,
//     };
//   }
// }

class ClientProfileModel {
  final bool status;
  final String message;
  final ClientData? data;
  final dynamic errors;

  ClientProfileModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientProfileModel(
        status: false,
        message: '',
        data: null,
        errors: null,
      );
    }

    return ClientProfileModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? ClientData.fromJson(
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

class ClientData {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String countryCode;
  final String passwordHistory;
  final String passwordResetFlag;
  final String role;
  final String accountManagerId;
  final String? profileImage;
  final String lastLogin;
  final String lastIp;
  final String? resetToken;
  final String? tokenExpiresAt;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? deleteScheduledAt;
  final String ownReferralCode;
  final String? referredByUserId;
  final String? referredAt;

  ClientData({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.countryCode,
    required this.passwordHistory,
    required this.passwordResetFlag,
    required this.role,
    required this.accountManagerId,
    this.profileImage,
    required this.lastLogin,
    required this.lastIp,
    this.resetToken,
    this.tokenExpiresAt,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deleteScheduledAt,
    required this.ownReferralCode,
    this.referredByUserId,
    this.referredAt,
  });

  factory ClientData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientData(
        userId: '',
        name: '',
        email: '',
        phone: '',
        countryCode: '',
        passwordHistory: '',
        passwordResetFlag: '',
        role: '',
        accountManagerId: '',
        profileImage: null,
        lastLogin: '',
        lastIp: '',
        resetToken: null,
        tokenExpiresAt: null,
        status: '',
        createdAt: '',
        updatedAt: null,
        deletedAt: null,
        deleteScheduledAt: null,
        ownReferralCode: '',
        referredByUserId: null,
        referredAt: null,
      );
    }

    return ClientData(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      passwordHistory: json['password_history']?.toString() ?? '',
      passwordResetFlag: json['password_reset_flag']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      accountManagerId: json['account_manager_id']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      lastLogin: json['last_login']?.toString() ?? '',
      lastIp: json['last_ip']?.toString() ?? '',
      resetToken: json['reset_token']?.toString(),
      tokenExpiresAt: json['token_expires_at']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
      deletedAt: json['deleted_at']?.toString(),
      deleteScheduledAt: json['delete_scheduled_at']?.toString(),
      ownReferralCode: json['own_referral_code']?.toString() ?? '',
      referredByUserId: json['referred_by_user_id']?.toString(),
      referredAt: json['referred_at']?.toString(),
    );
  }

  /// True when the profile API indicates account deletion is scheduled.
  bool get isDeletionScheduled {
    if ((deleteScheduledAt ?? '').trim().isNotEmpty) {
      return true;
    }

    if ((deletedAt ?? '').trim().isNotEmpty) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'country_code': countryCode,
      'password_history': passwordHistory,
      'password_reset_flag': passwordResetFlag,
      'role': role,
      'account_manager_id': accountManagerId,
      'profile_image': profileImage,
      'last_login': lastLogin,
      'last_ip': lastIp,
      'reset_token': resetToken,
      'token_expires_at': tokenExpiresAt,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt,
      'delete_scheduled_at': deleteScheduledAt,
      'own_referral_code': ownReferralCode,
      'referred_by_user_id': referredByUserId,
      'referred_at': referredAt,
    };
  }
}