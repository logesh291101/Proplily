import 'package:flutter/material.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/client/widgets/client_notification_app_bar_action.dart';

/// PropLilly logo for [AppBar.actions] — consistent branding across modules.
class ProplillyAppBarLogoAction extends StatelessWidget {
  const ProplillyAppBarLogoAction({super.key});

  static const double radius = 18;
  static const EdgeInsets trailingPadding = EdgeInsets.only(right: 12);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: trailingPadding,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ClipOval(
            child: Image.asset(
              'assets/proplilly_logo.jfif',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => Icon(
                Icons.home_work_rounded,
                size: radius,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared [AppBar] action helpers for Client and Field Agent screens.
abstract final class ProplillyAppBar {
  /// Client module AppBar actions: notification bell + PropLilly logo.
  static List<Widget> clientActions({
    List<Widget>? additional,
    bool includeNotification = true,
  }) =>
      [
        ...?additional,
        if (includeNotification) const ClientNotificationAppBarAction(),
        const ProplillyAppBarLogoAction(),
      ];

  /// Field Agent and legacy screens: PropLilly logo only.
  static List<Widget> logoActions({List<Widget>? additional}) => [
        ...?additional,
        const ProplillyAppBarLogoAction(),
      ];

  /// Minimal app bar for screens whose title lives in a gradient hero below.
  static PreferredSizeWidget heroOverlay({
    List<Widget>? additionalActions,
    bool clientModule = false,
  }) {
    return AppBar(
      title: const SizedBox.shrink(),
      actions: clientModule
          ? clientActions(additional: additionalActions)
          : logoActions(additional: additionalActions),
    );
  }

  /// Client hero overlay with notification icon.
  static PreferredSizeWidget clientHeroOverlay({
    List<Widget>? additionalActions,
  }) {
    return heroOverlay(
      additionalActions: additionalActions,
      clientModule: true,
    );
  }
}
