import 'package:proplilly/client/models/client_billing_details.dart';

class ClientBillingModel {
  final bool status;
  final String message;
  final List<BillingHistory> data;
  final dynamic errors;

  ClientBillingModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientBillingModel.fromJson(Map<String, dynamic> json) {
    return ClientBillingModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: parseBillingList(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }

  static bool _parseStatus(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      return t == '200' || t == 'true';
    }
    return false;
  }

  static List<BillingHistory> parseBillingList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => BillingHistory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map) {
      return [
        BillingHistory.fromJson(Map<String, dynamic>.from(raw)),
      ];
    }

    return [];
  }
}

/// Maps legacy [BillingDetails] to [BillingHistory] for widget compatibility.
BillingHistory billingHistoryFromLegacy(BillingDetails details) {
  return BillingHistory(
    subscriptionId: details.transactionId,
    userId: '',
    planId: '',
    startDate: details.durationStart,
    endDate: details.durationEnd,
    status: details.paymentStatus.name,
    paymentStatus: details.paymentStatus.name,
    transactionId: details.transactionId,
    createdAt: details.transactionDate,
    updatedAt: details.transactionDate,
    planName: details.planName,
    planPrice: details.planPrice,
  );
}

class BillingHistory {
  final String subscriptionId;
  final String userId;
  final String planId;
  final String startDate;
  final String endDate;
  final String status;
  final String paymentStatus;
  final String transactionId;
  final String createdAt;
  final String updatedAt;
  final String planName;
  final String planPrice;

  BillingHistory({
    required this.subscriptionId,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentStatus,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    required this.planName,
    required this.planPrice,
  });

  factory BillingHistory.fromJson(Map<String, dynamic> json) {
    return BillingHistory(
      subscriptionId: json['subscription_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      planId: json['plan_id']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      planName: json['plan_name']?.toString() ?? '',
      planPrice: json['plan_price']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'user_id': userId,
      'plan_id': planId,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'plan_name': planName,
      'plan_price': planPrice,
    };
  }
}
