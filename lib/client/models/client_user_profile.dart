// import 'package:proplilly/client/models/client_home_dashboard.dart';
//
// /// Profile UI data mapped from [ClientProfileModel] for profile widgets.
// class UserProfile {
//   const UserProfile({
//     required this.name,
//     required this.email,
//     required this.phoneNumber,
//     required this.subscriptionPlan,
//     required this.subscriptionStatus,
//     required this.memberSince,
//     required this.renewalDate,
//     required this.activities,
//     this.profileImage,
//   });
//
//   final String name;
//   final String email;
//   final String phoneNumber;
//   final String subscriptionPlan;
//   final SubscriptionStatus subscriptionStatus;
//   final String memberSince;
//   final String renewalDate;
//   final List<ActivityItem> activities;
//   final String? profileImage;
//
//   String get avatarLetter {
//     final trimmed = name.trim();
//     if (trimmed.isEmpty) return '?';
//     return trimmed[0].toUpperCase();
//   }
//
//   String get initials {
//     final parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty || parts.first.isEmpty) return '?';
//     if (parts.length == 1) {
//       return parts.first.substring(0, 1).toUpperCase();
//     }
//     return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
//   }
//
//   String get firstName {
//     final parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty || parts.first.isEmpty) return 'there';
//     return parts.first;
//   }
// }
//
// enum SubscriptionStatus {
//   active,
//   expired;
//
//   String get label => switch (this) {
//         SubscriptionStatus.active => 'Active',
//         SubscriptionStatus.expired => 'Expired',
//       };
// }

import 'package:proplilly/client/models/client_home_dashboard.dart';

/// Profile UI data mapped from [ClientProfileModel] for profile widgets.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.email = '',
    this.phoneNumber = '',
    this.subscriptionPlan = '',
    this.subscriptionStatus = SubscriptionStatus.expired,
    this.memberSince = '',
    this.renewalDate = '',
    this.activities = const [],
    this.profileImage,
  });

  final String name;
  final String email;
  final String phoneNumber;
  final String subscriptionPlan;
  final SubscriptionStatus subscriptionStatus;
  final String memberSince;
  final String renewalDate;
  final List<ActivityItem> activities;
  final String? profileImage;

  String get avatarLetter {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'there';

    return trimmed.split(RegExp(r'\s+')).first;
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
