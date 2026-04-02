import 'property_model.dart';

class UserDashboard {
  final int propertiesCount;
  final List<Property> properties;
  final String? lastInspection;
  final List<Activity> recentActivities;
  final String? currentPlan;

  UserDashboard({
    required this.propertiesCount,
    required this.properties,
    this.lastInspection,
    required this.recentActivities,
    this.currentPlan,
  });

  factory UserDashboard.fromJson(Map<String, dynamic> json) {
    return UserDashboard(
      propertiesCount: json['properties_count'] ?? 0,
      properties: (json['properties'] as List? ?? [])
          .map((p) => Property.fromJson(p))
          .toList(),
      lastInspection: json['last_inspection'] as String?,
      recentActivities: (json['recent_activities'] as List? ?? [])
          .map((a) => Activity.fromJson(a))
          .toList(),
      currentPlan: json['current_plan'] as String?,
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final String date;
  final String type;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: json['date'] as String,
      type: json['type'] as String,
    );
  }
}
