// To parse this JSON data, do
//
//     final clientDashboardModel = clientDashboardModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ClientDashboardModel clientDashboardModelFromJson(String str) => ClientDashboardModel.fromJson(json.decode(str));

String clientDashboardModelToJson(ClientDashboardModel data) => json.encode(data.toJson());

class ClientDashboardModel {
  bool status;
  String message;
  Data data;
  dynamic errors;

  ClientDashboardModel({
    required this.status,
    required this.message,
    required this.data,
    required this.errors,
  });

  factory ClientDashboardModel.fromJson(Map<String, dynamic> json) => ClientDashboardModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
    errors: json["errors"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
    "errors": errors,
  };
}

class Data {
  User user;
  Stats stats;
  CurrentPlan currentPlan;
  List<RecentActivity> recentActivities;
  List<dynamic> ads;

  Data({
    required this.user,
    required this.stats,
    required this.currentPlan,
    required this.recentActivities,
    required this.ads,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: User.fromJson(json["user"]),
    stats: Stats.fromJson(json["stats"]),
    currentPlan: CurrentPlan.fromJson(json["current_plan"]),
    recentActivities: List<RecentActivity>.from(json["recent_activities"].map((x) => RecentActivity.fromJson(x))),
    ads: List<dynamic>.from(json["ads"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "user": user.toJson(),
    "stats": stats.toJson(),
    "current_plan": currentPlan.toJson(),
    "recent_activities": List<dynamic>.from(recentActivities.map((x) => x.toJson())),
    "ads": List<dynamic>.from(ads.map((x) => x)),
  };
}

class CurrentPlan {
  String planName;
  String paymentStatus;
  DateTime endDate;

  CurrentPlan({
    required this.planName,
    required this.paymentStatus,
    required this.endDate,
  });

  factory CurrentPlan.fromJson(Map<String, dynamic> json) => CurrentPlan(
    planName: json["plan_name"],
    paymentStatus: json["payment_status"],
    endDate: DateTime.parse(json["end_date"]),
  );

  Map<String, dynamic> toJson() => {
    "plan_name": planName,
    "payment_status": paymentStatus,
    "end_date": endDate.toIso8601String(),
  };
}

class RecentActivity {
  String notificationId;
  String userId;
  dynamic contextClientId;
  String title;
  String message;
  dynamic image;
  dynamic redirectUrl;
  String isRead;
  String createdBy;
  DateTime createdAt;
  dynamic updatedBy;
  DateTime updatedAt;

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

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
    notificationId: json["notification_id"],
    userId: json["user_id"],
    contextClientId: json["context_client_id"],
    title: json["title"],
    message: json["message"],
    image: json["image"],
    redirectUrl: json["redirect_url"],
    isRead: json["is_read"],
    createdBy: json["created_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedBy: json["updated_by"],
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "notification_id": notificationId,
    "user_id": userId,
    "context_client_id": contextClientId,
    "title": title,
    "message": message,
    "image": image,
    "redirect_url": redirectUrl,
    "is_read": isRead,
    "created_by": createdBy,
    "created_at": createdAt.toIso8601String(),
    "updated_by": updatedBy,
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Stats {
  int propertyCount;

  Stats({
    required this.propertyCount,
  });

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    propertyCount: json["property_count"],
  );

  Map<String, dynamic> toJson() => {
    "property_count": propertyCount,
  };
}

class User {
  String userId;
  String name;
  String email;
  String phone;
  dynamic profileImage;
  DateTime createdAt;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["user_id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    profileImage: json["profile_image"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "email": email,
    "phone": phone,
    "profile_image": profileImage,
    "created_at": createdAt.toIso8601String(),
  };
}
