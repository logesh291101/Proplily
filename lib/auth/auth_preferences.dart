/// SharedPreferences keys for authenticated user data.
abstract final class AuthPreferenceKeys {
  static const String token = 'token';
  static const String userId = 'user_id';
  static const String email = 'email';
  static const String role = 'role';
  static const String name = 'name';

  static const String phone = 'phone';
  static const String subscriptionPlan = 'subscription_plan';
  static const String subscriptionStatus = 'subscription_status';
  static const String memberSince = 'member_since';
  static const String renewalDate = 'renewal_date';

  /// Written on successful login.
  static const List<String> loginKeys = [
    token,
    userId,
    email,
    role,
    name,
  ];

  /// All user-related keys cleared on logout (`live_url` is not included).
  static const List<String> keysClearedOnLogout = [
    ...loginKeys,
    phone,
    subscriptionPlan,
    subscriptionStatus,
    memberSince,
    renewalDate,
    'jwt',
    // Legacy key — no longer written; cleared so old sessions do not retain it.
    'user_type',
  ];
}
