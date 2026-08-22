import 'package:proplilly/fieldagent/fieldagent_referral_list_model.dart';

extension FieldAgentReferralUi on FieldAgentReferral {
  String displayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty ? trimmed : '—';
  }

  String get displayReferredName => displayValue(referredName);
  String get displayReferredEmail => displayValue(referredEmail);
  String get displayJoinedAt => displayValue(joinedAt);
  String get displayStatusLabel => displayValue(statusLabel);
}
