/// Platform-specific app update configuration.
class AppUpdateConfig {
  const AppUpdateConfig({
    required this.forceUpdate,
    required this.version,
    required this.reason,
    required this.storeUrl,
  });

  /// Whether the update is mandatory (`"true"` / `"false"` from config).
  final String forceUpdate;

  /// Target store version to compare against the installed app version.
  final String version;

  /// Message shown in the update dialog.
  final String reason;

  /// Play Store or App Store URL opened by the Update action.
  final String storeUrl;

  bool get isForceUpdate => forceUpdate.trim().toLowerCase() == 'true';
}
