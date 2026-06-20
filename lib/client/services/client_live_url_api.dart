import 'package:proplilly/remote_config/remote_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared helpers for endpoints under `live_url` from SharedPreferences.
abstract final class LiveUrlApi {
  /// Returns trimmed base URL without trailing slash, or null if missing.
  static Future<String?> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(RemoteConfigKeys.liveUrl)?.trim() ?? '';
    if (raw.isEmpty) return null;
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  /// Builds `{base}/api/{suffix}` e.g. suffix `forgot-password` → `/api/forgot-password`.
  static Uri? endpoint(String base, String apiSuffix) {
    final uri = Uri.tryParse('$base/api/$apiSuffix');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }
}
