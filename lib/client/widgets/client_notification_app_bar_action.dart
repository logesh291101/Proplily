import 'package:flutter/material.dart';
import 'package:proplilly/client/providers/client_notification_provider.dart';
import 'package:proplilly/client/screens/client_notification_screen.dart';
import 'package:proplilly/client/theme/app_colors.dart';

/// Notification bell with unread badge for Client module AppBars.
class ClientNotificationAppBarAction extends StatefulWidget {
  const ClientNotificationAppBarAction({super.key});

  @override
  State<ClientNotificationAppBarAction> createState() =>
      _ClientNotificationAppBarActionState();
}

class _ClientNotificationAppBarActionState
    extends State<ClientNotificationAppBarAction> {
  final _provider = ClientNotificationProvider.shared();

  @override
  void initState() {
    super.initState();
    _provider.addListener(_onProviderChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ClientNotificationScreen(),
      ),
    );
    if (!mounted) return;
    await _provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _provider.unreadCount;

    return IconButton(
      tooltip: 'Notifications',
      onPressed: _openNotifications,
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text('$unreadCount'),
        backgroundColor: AppColors.error,
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
