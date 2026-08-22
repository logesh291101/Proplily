// // To parse this JSON data, do
// //
// //     final clientDashboardModel = clientDashboardModelFromJson(jsonString);
//
// import 'package:meta/meta.dart';
// import 'dart:convert';
//
// ClientDashboardModel clientDashboardModelFromJson(String str) => ClientDashboardModel.fromJson(json.decode(str));
//
// String clientDashboardModelToJson(ClientDashboardModel data) => json.encode(data.toJson());
//
// class ClientDashboardModel {
//   bool status;
//   String message;
//   Data data;
//   dynamic errors;
//
//   ClientDashboardModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     required this.errors,
//   });
//
//   factory ClientDashboardModel.fromJson(Map<String, dynamic> json) => ClientDashboardModel(
//     status: json["status"],
//     message: json["message"],
//     data: Data.fromJson(json["data"]),
//     errors: json["errors"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//     "data": data.toJson(),
//     "errors": errors,
//   };
// }
//
// class Data {
//   User user;
//   Stats stats;
//   CurrentPlan currentPlan;
//   List<RecentActivity> recentActivities;
//   List<dynamic> ads;
//
//   Data({
//     required this.user,
//     required this.stats,
//     required this.currentPlan,
//     required this.recentActivities,
//     required this.ads,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     user: User.fromJson(json["user"]),
//     stats: Stats.fromJson(json["stats"]),
//     currentPlan: CurrentPlan.fromJson(json["current_plan"]),
//     recentActivities: List<RecentActivity>.from(json["recent_activities"].map((x) => RecentActivity.fromJson(x))),
//     ads: List<dynamic>.from(json["ads"].map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "user": user.toJson(),
//     "stats": stats.toJson(),
//     "current_plan": currentPlan.toJson(),
//     "recent_activities": List<dynamic>.from(recentActivities.map((x) => x.toJson())),
//     "ads": List<dynamic>.from(ads.map((x) => x)),
//   };
// }
//
// class CurrentPlan {
//   String planName;
//   String paymentStatus;
//   DateTime endDate;
//
//   CurrentPlan({
//     required this.planName,
//     required this.paymentStatus,
//     required this.endDate,
//   });
//
//   factory CurrentPlan.fromJson(Map<String, dynamic> json) => CurrentPlan(
//     planName: json["plan_name"],
//     paymentStatus: json["payment_status"],
//     endDate: DateTime.parse(json["end_date"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "plan_name": planName,
//     "payment_status": paymentStatus,
//     "end_date": endDate.toIso8601String(),
//   };
// }
//
// class RecentActivity {
//   String notificationId;
//   String userId;
//   dynamic contextClientId;
//   String title;
//   String message;
//   dynamic image;
//   dynamic redirectUrl;
//   String isRead;
//   String createdBy;
//   DateTime createdAt;
//   dynamic updatedBy;
//   DateTime updatedAt;
//
//   RecentActivity({
//     required this.notificationId,
//     required this.userId,
//     required this.contextClientId,
//     required this.title,
//     required this.message,
//     required this.image,
//     required this.redirectUrl,
//     required this.isRead,
//     required this.createdBy,
//     required this.createdAt,
//     required this.updatedBy,
//     required this.updatedAt,
//   });
//
//   factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
//     notificationId: json["notification_id"],
//     userId: json["user_id"],
//     contextClientId: json["context_client_id"],
//     title: json["title"],
//     message: json["message"],
//     image: json["image"],
//     redirectUrl: json["redirect_url"],
//     isRead: json["is_read"],
//     createdBy: json["created_by"],
//     createdAt: DateTime.parse(json["created_at"]),
//     updatedBy: json["updated_by"],
//     updatedAt: DateTime.parse(json["updated_at"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "notification_id": notificationId,
//     "user_id": userId,
//     "context_client_id": contextClientId,
//     "title": title,
//     "message": message,
//     "image": image,
//     "redirect_url": redirectUrl,
//     "is_read": isRead,
//     "created_by": createdBy,
//     "created_at": createdAt.toIso8601String(),
//     "updated_by": updatedBy,
//     "updated_at": updatedAt.toIso8601String(),
//   };
// }
//
// class Stats {
//   int propertyCount;
//
//   Stats({
//     required this.propertyCount,
//   });
//
//   factory Stats.fromJson(Map<String, dynamic> json) => Stats(
//     propertyCount: json["property_count"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "property_count": propertyCount,
//   };
// }
//
// class User {
//   String userId;
//   String name;
//   String email;
//   String phone;
//   dynamic profileImage;
//   DateTime createdAt;
//
//   User({
//     required this.userId,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.profileImage,
//     required this.createdAt,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//     userId: json["user_id"],
//     name: json["name"],
//     email: json["email"],
//     phone: json["phone"],
//     profileImage: json["profile_image"],
//     createdAt: DateTime.parse(json["created_at"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "user_id": userId,
//     "name": name,
//     "email": email,
//     "phone": phone,
//     "profile_image": profileImage,
//     "created_at": createdAt.toIso8601String(),
//   };
// }


import 'dart:convert';

ClientDashboardModel clientDashboardModelFromJson(String str) =>
    ClientDashboardModel.fromJson(json.decode(str));

String clientDashboardModelToJson(ClientDashboardModel data) =>
    json.encode(data.toJson());

class ClientDashboardModel {
  final bool status;
  final String message;
  final DashboardData data;
  final dynamic errors;

  ClientDashboardModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientDashboardModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientDashboardModel(
        status: false,
        message: '',
        data: DashboardData.empty(),
        errors: null,
      );
    }

    return ClientDashboardModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: DashboardData.fromJson(_mapFromDynamic(json['data'])),
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

  bool get isSuccess => status;

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

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return null;
  }
}

class DashboardData {
  final DashboardUser user;
  final DashboardStats stats;
  final CurrentPlan currentPlan;
  final List<RecentActivity> recentActivities;
  final List<dynamic> ads;

  DashboardData({
    required this.user,
    required this.stats,
    required this.currentPlan,
    required this.recentActivities,
    required this.ads,
  });

  factory DashboardData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardData.empty();
    }

    return DashboardData(
      user: DashboardUser.fromJson(
        _mapFromDynamic(json['user']),
      ),
      stats: DashboardStats.fromJson(
        _mapFromDynamic(json['stats']),
      ),
      currentPlan: CurrentPlan.fromJson(
        _mapFromDynamic(json['current_plan']),
      ),
      recentActivities: _parseRecentActivities(
        json['recent_activities'],
      ),
      ads: _parseAds(json['ads']),
    );
  }

  factory DashboardData.empty() {
    return DashboardData(
      user: DashboardUser.empty(),
      stats: DashboardStats.empty(),
      currentPlan: CurrentPlan.empty(),
      recentActivities: const [],
      ads: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'stats': stats.toJson(),
      'current_plan': currentPlan.toJson(),
      'recent_activities':
      recentActivities.map((e) => e.toJson()).toList(),
      'ads': ads,
    };
  }

  static List<RecentActivity> _parseRecentActivities(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => RecentActivity.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        RecentActivity.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }

  static List<dynamic> _parseAds(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return List<dynamic>.from(raw);
    }

    if (raw is Map) {
      return [Map<String, dynamic>.from(raw)];
    }

    return [];
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;

    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }

    return null;
  }
}

class CurrentPlan {
  final String planName;
  final String paymentStatus;
  final String endDate;

  CurrentPlan({
    required this.planName,
    required this.paymentStatus,
    required this.endDate,
  });

  factory CurrentPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CurrentPlan.empty();
    }

    return CurrentPlan(
      planName: json['plan_name']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
    );
  }

  factory CurrentPlan.empty() {
    return CurrentPlan(
      planName: '',
      paymentStatus: '',
      endDate: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_name': planName,
      'payment_status': paymentStatus,
      'end_date': endDate,
    };
  }
}

class RecentActivity {
  final String notificationId;
  final String userId;
  final String contextClientId;
  final String title;
  final String message;
  final String image;
  final String redirectUrl;
  final String isRead;
  final String createdBy;
  final String createdAt;
  final String updatedBy;
  final String updatedAt;

  RecentActivity({
    required this.notificationId,
    required this.userId,
    required this.contextClientId,
    required this.title,
    required this.message,
    required this.image,
    required this.redirectUrl,
    required this.isRead,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory RecentActivity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RecentActivity.empty();
    }

    return RecentActivity(
      notificationId:
      json['notification_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      contextClientId:
      json['context_client_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      redirectUrl: json['redirect_url']?.toString() ?? '',
      isRead: json['is_read']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  factory RecentActivity.empty() {
    return RecentActivity(
      notificationId: '',
      userId: '',
      contextClientId: '',
      title: '',
      message: '',
      image: '',
      redirectUrl: '',
      isRead: '',
      createdBy: '',
      createdAt: '',
      updatedBy: '',
      updatedAt: '',
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

class DashboardStats {
  final int propertyCount;

  DashboardStats({
    required this.propertyCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardStats.empty();
    }

    return DashboardStats(
      propertyCount: _parseInt(json['property_count']),
    );
  }

  factory DashboardStats.empty() {
    return DashboardStats(propertyCount: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'property_count': propertyCount,
    };
  }

  static int _parseInt(dynamic raw) {
    if (raw == null) return 0;

    if (raw is int) return raw;

    if (raw is num) return raw.toInt();

    if (raw is String) {
      return int.tryParse(raw.trim()) ?? 0;
    }

    return 0;
  }
}

class DashboardUser {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String createdAt;

  DashboardUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.createdAt,
  });

  factory DashboardUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DashboardUser.empty();
    }

    return DashboardUser(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  factory DashboardUser.empty() {
    return DashboardUser(
      userId: '',
      name: '',
      email: '',
      phone: '',
      profileImage: '',
      createdAt: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'created_at': createdAt,
    };
  }
}