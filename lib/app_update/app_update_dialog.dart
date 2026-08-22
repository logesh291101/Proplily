import 'package:flutter/material.dart';
import 'package:proplilly/app_update/app_update_config.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the shared Update Available dialog.
///
/// When [config.isForceUpdate] is true, the dialog cannot be dismissed via
/// back, outside tap, or Update Later.
Future<void> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdateConfig config,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !config.isForceUpdate,
    builder: (dialogContext) {
      return PopScope(
        canPop: !config.isForceUpdate,
        child: _AppUpdateDialog(config: config),
      );
    },
  );
}

class _AppUpdateDialog extends StatelessWidget {
  const _AppUpdateDialog({required this.config});

  final AppUpdateConfig config;

  Future<void> _openStore(BuildContext context) async {
    final raw = config.storeUrl.trim();
    if (raw.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store link is unavailable.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(raw);
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store link is invalid.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the store.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = config.reason.trim();

    return AlertDialog(
      title: const Text('Update Available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${config.version.trim()}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
      actions: [
        if (!config.isForceUpdate)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Update Later'),
          ),
        FilledButton(
          onPressed: () => _openStore(context),
          child: const Text('Update'),
        ),
      ],
    );
  }
}
