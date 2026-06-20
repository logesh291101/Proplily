import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firebase Remote Config parameter names (must match the Firebase console).
abstract final class RemoteConfigKeys {
  static const String androidVersion = 'android_version';
  static const String androidUpdateReason = 'androidupdate_reason';
  static const String appstoreUrl = 'appstore_url';
  static const String forceUpdate = 'force_update';
  static const String iosVersion = 'ios_version';
  static const String iosUpdateReason = 'iosupdate_reason';
  static const String liveUrl = 'live_url';
  static const String playstoreUrl = 'playstore_url';

  static const List<String> all = [
    androidVersion,
    androidUpdateReason,
    appstoreUrl,
    forceUpdate,
    iosVersion,
    iosUpdateReason,
    liveUrl,
    playstoreUrl,
  ];
}

/// Default values used when Remote Config is unavailable or a key is missing.
///
/// Keep these aligned with `setDefaults` in Firebase and with your release policy.
abstract final class RemoteConfigDefaults {
  static const String androidVersion = '1.0.0';
  static const String androidUpdateReason = '';
  static const String appstoreUrl = '';
  static const bool forceUpdate = false;
  static const String iosVersion = '1.0.0';
  static const String iosUpdateReason = '';
  static const String liveUrl = '';
  static const String playstoreUrl = '';

  static Map<String, Object> get asFirebaseDefaults => {
        RemoteConfigKeys.androidVersion: androidVersion,
        RemoteConfigKeys.androidUpdateReason: androidUpdateReason,
        RemoteConfigKeys.appstoreUrl: appstoreUrl,
        RemoteConfigKeys.forceUpdate: forceUpdate,
        RemoteConfigKeys.iosVersion: iosVersion,
        RemoteConfigKeys.iosUpdateReason: iosUpdateReason,
        RemoteConfigKeys.liveUrl: liveUrl,
        RemoteConfigKeys.playstoreUrl: playstoreUrl,
      };
}

/// Fetches [FirebaseRemoteConfig], applies in-app defaults, persists values to
/// [SharedPreferences] using the same keys as Remote Config.
///
/// Call [initialize] once at startup (after [WidgetsFlutterBinding.ensureInitialized]).
class RemoteConfigService {
  RemoteConfigService._();

  static SharedPreferences? _prefs;
  static FirebaseRemoteConfig? _remoteConfig;
  static Future<void>? _initFuture;

  static SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw StateError(
        'RemoteConfigService not initialized. Call initialize() first.',
      );
    }
    return p;
  }

  /// Remote Config instance when Firebase initialized successfully; otherwise null.
  static FirebaseRemoteConfig? get remoteConfigOrNull => _remoteConfig;

  /// Ensures Firebase + Remote Config + SharedPreferences are ready.
  ///
  /// If Firebase or fetch fails, defaults are still written to SharedPreferences
  /// so the rest of the app can read stable keys.
  static Future<void> initialize() => _initFuture ??= _doInitialize();

  static Future<void> _doInitialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RemoteConfigService: SharedPreferences failed: $e\n$st');
      }
      rethrow;
    }

    try {
      await Firebase.initializeApp();
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: kDebugMode
              ? Duration.zero
              : const Duration(hours: 12),
        ),
      );

      await _remoteConfig!.setDefaults(RemoteConfigDefaults.asFirebaseDefaults);

      try {
        await _remoteConfig!.fetchAndActivate();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint(
            'RemoteConfigService: fetchAndActivate failed: $e\n$st',
          );
        }
      }

      await persistFromRemoteConfig(_remoteConfig!);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RemoteConfigService: Firebase/Remote Config failed: $e\n$st');
      }
      _remoteConfig = null;
      await persistDefaultsOnly();
    }
  }

  /// Refreshes Remote Config from the network and updates SharedPreferences.
  static Future<void> refresh() async {
    await initialize();
    final rc = _remoteConfig;
    if (rc == null) {
      if (kDebugMode) {
        debugPrint(
          'RemoteConfigService: refresh skipped (Firebase unavailable)',
        );
      }
      return;
    }
    try {
      await rc.fetchAndActivate();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('RemoteConfigService: refresh failed: $e\n$st');
      }
    }
    await persistFromRemoteConfig(rc);
  }

  static Future<void> persistFromRemoteConfig(FirebaseRemoteConfig rc) async {
    final p = prefs;

    await Future.wait([
      p.setString(
        RemoteConfigKeys.androidVersion,
        rc.getString(RemoteConfigKeys.androidVersion),
      ),
      p.setString(
        RemoteConfigKeys.androidUpdateReason,
        rc.getString(RemoteConfigKeys.androidUpdateReason),
      ),
      p.setString(
        RemoteConfigKeys.appstoreUrl,
        rc.getString(RemoteConfigKeys.appstoreUrl),
      ),
      p.setBool(
        RemoteConfigKeys.forceUpdate,
        rc.getBool(RemoteConfigKeys.forceUpdate),
      ),
      p.setString(
        RemoteConfigKeys.iosVersion,
        rc.getString(RemoteConfigKeys.iosVersion),
      ),
      p.setString(
        RemoteConfigKeys.iosUpdateReason,
        rc.getString(RemoteConfigKeys.iosUpdateReason),
      ),
      p.setString(
        RemoteConfigKeys.liveUrl,
        rc.getString(RemoteConfigKeys.liveUrl),
      ),
      p.setString(
        RemoteConfigKeys.playstoreUrl,
        rc.getString(RemoteConfigKeys.playstoreUrl),
      ),
    ]);
  }

  /// Persist only default values to SharedPreferences (e.g. when RC never activated).
  static Future<void> persistDefaultsOnly() async {
    final p = prefs;
    await Future.wait([
      p.setString(RemoteConfigKeys.androidVersion, RemoteConfigDefaults.androidVersion),
      p.setString(
        RemoteConfigKeys.androidUpdateReason,
        RemoteConfigDefaults.androidUpdateReason,
      ),
      p.setString(RemoteConfigKeys.appstoreUrl, RemoteConfigDefaults.appstoreUrl),
      p.setBool(RemoteConfigKeys.forceUpdate, RemoteConfigDefaults.forceUpdate),
      p.setString(RemoteConfigKeys.iosVersion, RemoteConfigDefaults.iosVersion),
      p.setString(
        RemoteConfigKeys.iosUpdateReason,
        RemoteConfigDefaults.iosUpdateReason,
      ),
      p.setString(RemoteConfigKeys.liveUrl, RemoteConfigDefaults.liveUrl),
      p.setString(
        RemoteConfigKeys.playstoreUrl,
        RemoteConfigDefaults.playstoreUrl,
      ),
    ]);
  }

  // --- Typed reads from SharedPreferences (safe before refresh if [initialize] ran) ---

  static String get androidVersion =>
      prefs.getString(RemoteConfigKeys.androidVersion) ??
      RemoteConfigDefaults.androidVersion;

  static String get androidUpdateReason =>
      prefs.getString(RemoteConfigKeys.androidUpdateReason) ??
      RemoteConfigDefaults.androidUpdateReason;

  static String get appstoreUrl =>
      prefs.getString(RemoteConfigKeys.appstoreUrl) ??
      RemoteConfigDefaults.appstoreUrl;

  static bool get forceUpdate =>
      prefs.getBool(RemoteConfigKeys.forceUpdate) ??
      RemoteConfigDefaults.forceUpdate;

  static String get iosVersion =>
      prefs.getString(RemoteConfigKeys.iosVersion) ??
      RemoteConfigDefaults.iosVersion;

  static String get iosUpdateReason =>
      prefs.getString(RemoteConfigKeys.iosUpdateReason) ??
      RemoteConfigDefaults.iosUpdateReason;

  static String get liveUrl =>
      prefs.getString(RemoteConfigKeys.liveUrl) ??
      RemoteConfigDefaults.liveUrl;

  static String get playstoreUrl =>
      prefs.getString(RemoteConfigKeys.playstoreUrl) ??
      RemoteConfigDefaults.playstoreUrl;
}
