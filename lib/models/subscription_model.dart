enum SubscriptionPlan {
  basic,
  premium,
}

enum SubscriptionPeriod {
  monthly,
  yearly,
}

enum SubscriptionStatus {
  active,
  expired,
  cancelled,
}

class Subscription {
  final String id;
  final String userId;
  final String propertyId;
  final SubscriptionPlan plan;
  final SubscriptionPeriod period;
  final double amount;
  final DateTime startDate;
  final DateTime expiryDate;
  final SubscriptionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.plan,
    required this.period,
    required this.amount,
    required this.startDate,
    required this.expiryDate,
    this.status = SubscriptionStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.toString().split('.').last == json['plan'],
        orElse: () => SubscriptionPlan.basic,
      ),
      period: SubscriptionPeriod.values.firstWhere(
        (e) => e.toString().split('.').last == json['period'],
        orElse: () => SubscriptionPeriod.monthly,
      ),
      amount: (json['amount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'plan': plan.toString().split('.').last,
      'period': period.toString().split('.').last,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
