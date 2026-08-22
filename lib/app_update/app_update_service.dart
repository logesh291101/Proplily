import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:proplilly/app_update/app_update_config.dart';
import 'package:proplilly/app_update/app_update_dialog.dart';
import 'package:proplilly/remote_config/remote_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared app-update checker for all roles.
///
/// Prefer values already stored in SharedPreferences; fall back to Firebase
/// Remote Config when required platform keys are missing.
abstract final class AppUpdateService {
  static bool _dialogVisible = false;

  /// Runs the platform update check and shows the dialog when versions differ.
  ///
  /// Call from any Home Screen after the widget is mounted (e.g. post-frame).
  static Future<void> checkAndPrompt(BuildContext context) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    if (_dialogVisible) return;

    try {
      final config = await loadPlatformConfig();
      if (config == null) return;

      final requiredVersion = config.version.trim();
      if (requiredVersion.isEmpty) return;
      if (config.storeUrl.trim().isEmpty) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.trim();
      if (currentVersion == requiredVersion) return;

      if (!context.mounted) return;

      _dialogVisible = true;
      try {
        await showAppUpdateDialog(context, config: config);
      } finally {
        _dialogVisible = false;
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: checkAndPrompt failed: $e\n$st');
      }
    }
  }

  /// Loads Android or iOS update config (prefs first, then Remote Config).
  static Future<AppUpdateConfig?> loadPlatformConfig() async {
    await RemoteConfigService.initialize();

    if (Platform.isAndroid) {
      return _loadAndroidConfig();
    }
    if (Platform.isIOS) {
      return _loadIosConfig();
    }
    return null;
  }

  static Future<AppUpdateConfig> _loadAndroidConfig() async {
    final prefs = await SharedPreferences.getInstance();

    var forceUpdate = _prefsString(prefs, RemoteConfigKeys.androidForceUpdate);
    var version = _prefsString(prefs, RemoteConfigKeys.androidVersion);
    var reason = _prefsString(prefs, RemoteConfigKeys.androidUpdateReason);
    var storeUrl = _prefsString(prefs, RemoteConfigKeys.playstoreUrl);

    if (_isMissing(forceUpdate) ||
        _isMissing(version) ||
        _isMissing(storeUrl)) {
      final fromRc = await _readFromRemoteConfig(
        forceUpdateKey: RemoteConfigKeys.androidForceUpdate,
        versionKey: RemoteConfigKeys.androidVersion,
        reasonKey: RemoteConfigKeys.androidUpdateReason,
        storeUrlKey: RemoteConfigKeys.playstoreUrl,
      );
      forceUpdate = _coalesce(forceUpdate, fromRc.forceUpdate);
      version = _coalesce(version, fromRc.version);
      reason = _coalesce(reason, fromRc.reason);
      storeUrl = _coalesce(storeUrl, fromRc.storeUrl);
    }

    return AppUpdateConfig(
      forceUpdate: forceUpdate.isEmpty
          ? RemoteConfigDefaults.androidForceUpdate
          : forceUpdate,
      version: version,
      reason: reason,
      storeUrl: storeUrl,
    );
  }

  static Future<AppUpdateConfig> _loadIosConfig() async {
    final prefs = await SharedPreferences.getInstance();

    var forceUpdate = _prefsString(prefs, RemoteConfigKeys.iosForceUpdate);
    var version = _prefsString(prefs, RemoteConfigKeys.iosVersion);
    var reason = _prefsString(prefs, RemoteConfigKeys.iosUpdateReason);
    var storeUrl = _prefsString(prefs, RemoteConfigKeys.appstoreUrl);

    if (_isMissing(forceUpdate) ||
        _isMissing(version) ||
        _isMissing(storeUrl)) {
      final fromRc = await _readFromRemoteConfig(
        forceUpdateKey: RemoteConfigKeys.iosForceUpdate,
        versionKey: RemoteConfigKeys.iosVersion,
        reasonKey: RemoteConfigKeys.iosUpdateReason,
        storeUrlKey: RemoteConfigKeys.appstoreUrl,
      );
      forceUpdate = _coalesce(forceUpdate, fromRc.forceUpdate);
      version = _coalesce(version, fromRc.version);
      reason = _coalesce(reason, fromRc.reason);
      storeUrl = _coalesce(storeUrl, fromRc.storeUrl);
    }

    return AppUpdateConfig(
      forceUpdate: forceUpdate.isEmpty
          ? RemoteConfigDefaults.iosForceUpdate
          : forceUpdate,
      version: version,
      reason: reason,
      storeUrl: storeUrl,
    );
  }

  static Future<AppUpdateConfig> _readFromRemoteConfig({
    required String forceUpdateKey,
    required String versionKey,
    required String reasonKey,
    required String storeUrlKey,
  }) async {
    FirebaseRemoteConfig? rc = RemoteConfigService.remoteConfigOrNull;
    if (rc == null) {
      await RemoteConfigService.initialize();
      rc = RemoteConfigService.remoteConfigOrNull;
    }

    if (rc == null) {
      return const AppUpdateConfig(
        forceUpdate: 'false',
        version: '',
        reason: '',
        storeUrl: '',
      );
    }

    try {
      await rc.fetchAndActivate();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppUpdateService: Remote Config fetch failed: $e\n$st');
      }
    }

    await RemoteConfigService.persistFromRemoteConfig(rc);

    return AppUpdateConfig(
      forceUpdate: rc.getString(forceUpdateKey).trim(),
      version: rc.getString(versionKey).trim(),
      reason: rc.getString(reasonKey).trim(),
      storeUrl: rc.getString(storeUrlKey).trim(),
    );
  }

  static String _prefsString(SharedPreferences prefs, String key) {
    return prefs.getString(key)?.trim() ?? '';
  }

  static bool _isMissing(String value) => value.isEmpty;

  static String _coalesce(String preferred, String fallback) {
    return preferred.isNotEmpty ? preferred : fallback;
  }
}
