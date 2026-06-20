import 'package:proplilly/client/models/client_home_dashboard.dart';

/// Profile UI data mapped from [ClientProfileModel] for profile widgets.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    required this.memberSince,
    required this.renewalDate,
    required this.activities,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String subscriptionPlan;
  final SubscriptionStatus subscriptionStatus;
  final String memberSince;
  final String renewalDate;
  final List<ActivityItem> activities;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'there';
    return parts.first;
  }
}

enum SubscriptionStatus {
  active,
  expired;

  String get label => switch (this) {
        SubscriptionStatus.active => 'Active',
        SubscriptionStatus.expired => 'Expired',
      };
}
