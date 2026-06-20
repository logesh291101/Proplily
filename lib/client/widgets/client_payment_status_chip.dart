import 'package:flutter/material.dart';
import 'package:proplilly/client/models/client_billing_details.dart';
import 'package:proplilly/client/widgets/premium/premium_status_chip.dart';

/// Payment status badge for billing screens.
class PaymentStatusChip extends StatelessWidget {
  const PaymentStatusChip({
    super.key,
    required this.status,
  });

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    return PremiumStatusChip(
      label: status.label,
      color: status.highlightColor,
      isPositive: status.isPositive,
    );
  }
}
