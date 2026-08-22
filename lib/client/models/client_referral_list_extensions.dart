import 'package:proplilly/client/models/client_referral_list_model.dart';

extension ClientReferralUi on ClientReferral {
  String displayValue(String raw) {
    final trimmed = raw.trim();
    return trimmed.isNotEmpty ? trimmed : '—';
  }

  String get displayReferredName => displayValue(referredName);
  String get displayReferredEmail => displayValue(referredEmail);
  String get displayJoinedAt => displayValue(joinedAt);
  String get displayStatusLabel => displayValue(statusLabel);
}
