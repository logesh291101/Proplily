import 'package:proplilly/services/auth_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clears locally stored user data from [SharedPreferences].
///
/// Does not call any API. [AuthPreferenceKeys.keysClearedOnLogout] are removed;
/// `live_url` and other remote-config keys are left unchanged.
class LogoutService {
  /// Removes all user-related preference keys. Returns `false` if any remove fails.
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();

    final results = await Future.wait<bool>(
      AuthPreferenceKeys.keysClearedOnLogout.map(prefs.remove),
    );

    return results.every((ok) => ok);
  }
}
