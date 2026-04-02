import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../theme/auth_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final isAdmin = user?.userType.toString().split('.').last == 'admin';
    
    final notifications = _notificationService.getNotificationsForUser(user?.id, isAdmin);

    return SafeArea(child: Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.where((n) => !n.isRead).isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _notificationService.markAllAsReadForUser(user?.id, isAdmin);
                });
              },
              child: const Text('Mark all as read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return ListTile(
                  tileColor: notif.isRead ? null : AuthTheme.primary.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: notif.isRead ? Colors.grey.shade200 : AuthTheme.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.notifications,
                      color: notif.isRead ? Colors.grey : AuthTheme.primary,
                    ),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${notif.message}\n${_formatDate(notif.createdAt)}',
                    style: const TextStyle(height: 1.4),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    if (!notif.isRead) {
                      setState(() {
                        _notificationService.markAsRead(notif.id);
                      });
                    }
                  },
                );
              },
            ),
    ));
  }

  String _formatDate(DateTime date) {
    final dur = DateTime.now().difference(date);
    if (dur.inMinutes < 60) return '${dur.inMinutes}m ago';
    if (dur.inHours < 24) return '${dur.inHours}h ago';
    return '${dur.inDays}d ago';
  }
}
