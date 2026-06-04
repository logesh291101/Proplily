import 'package:flutter/material.dart';

/// Legacy view model; prefer [BillingHistory] from [ClientBillingModel].
class BillingDetails {
  const BillingDetails({
    required this.planName,
    required this.planPrice,
    required this.memberSince,
    required this.renewalDate,
    required this.transactionId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.durationStart,
    required this.durationEnd,
    required this.transactionDate,
    required this.activities,
  });

  final String planName;
  final String planPrice;
  final String memberSince;
  final String renewalDate;
  final String transactionId;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final String durationStart;
  final String durationEnd;
  final String transactionDate;
  final List<BillingActivity> activities;

  String get durationRange => '$durationStart → $durationEnd';
}

/// Timeline entry for billing activity.
class BillingActivity {
  const BillingActivity({
    required this.title,
    required this.date,
    required this.icon,
    required this.color,
  });

  final String title;
  final String date;
  final IconData icon;
  final Color color;
}

enum PaymentStatus {
  completed,
  failed,
  expired,
  pending;

  static PaymentStatus fromString(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'completed':
      case 'success':
      case 'paid':
        return PaymentStatus.completed;
      case 'failed':
      case 'failure':
        return PaymentStatus.failed;
      case 'expired':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.pending;
    }
  }

  String get label {
    final name = toString().split('.').last;
    if (name.isEmpty) return name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  bool get isPositive => this == PaymentStatus.completed;

  Color get highlightColor {
    if (isPositive) return const Color(0xFF2E7D32);
    if (this == PaymentStatus.failed || this == PaymentStatus.expired) {
      return const Color(0xFFC62828);
    }
    return const Color(0xFFE65100);
  }
}
