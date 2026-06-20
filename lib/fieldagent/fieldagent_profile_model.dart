class FieldAgentProfileModel {
  final bool? status;
  final String? message;
  final FieldAgentProfileData? data;
  final dynamic errors;

  FieldAgentProfileModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory FieldAgentProfileModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentProfileModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? FieldAgentProfileData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
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
}

class FieldAgentProfileData {
  final String? userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? countryCode;
  final dynamic passwordHistory;
  final String? passwordResetFlag;
  final String? role;
  final String? accountManagerId;
  final String? profileImage;
  final String? lastLogin;
  final String? lastIp;
  final String? resetToken;
  final String? tokenExpiresAt;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? deleteScheduledAt;
  final String? ownReferralCode;
  final String? referredByUserId;
  final String? referredAt;

  FieldAgentProfileData({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.countryCode,
    this.passwordHistory,
    this.passwordResetFlag,
    this.role,
    this.accountManagerId,
    this.profileImage,
    this.lastLogin,
    this.lastIp,
    this.resetToken,
    this.tokenExpiresAt,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.deleteScheduledAt,
    this.ownReferralCode,
    this.referredByUserId,
    this.referredAt,
  });

  factory FieldAgentProfileData.fromJson(Map<String, dynamic> json) {
    return FieldAgentProfileData(
      userId: json['user_id']?.toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      countryCode: json['country_code'],
      passwordHistory: json['password_history'],
      passwordResetFlag: json['password_reset_flag']?.toString(),
      role: json['role'],
      accountManagerId: json['account_manager_id']?.toString(),
      profileImage: json['profile_image'],
      lastLogin: json['last_login'],
      lastIp: json['last_ip'],
      resetToken: json['reset_token'],
      tokenExpiresAt: json['token_expires_at'],
      status: json['status']?.toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
      deleteScheduledAt: json['delete_scheduled_at'],
      ownReferralCode: json['own_referral_code'],
      referredByUserId: json['referred_by_user_id']?.toString(),
      referredAt: json['referred_at'],
    );
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
