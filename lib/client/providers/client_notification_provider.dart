import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_notification_model.dart';
import 'package:proplilly/client/services/client_notification_service.dart';

/// Shared unread notification state for Client module AppBars.
class ClientNotificationProvider extends ChangeNotifier {
  ClientNotificationProvider({ClientNotificationService? service})
      : _service = service ?? ClientNotificationService();

  static ClientNotificationProvider? _shared;

  static ClientNotificationProvider shared() {
    return _shared ??= ClientNotificationProvider();
  }

  static void reset() {
    _shared?.dispose();
    _shared = null;
  }

  final ClientNotificationService _service;

  bool _isLoading = false;
  int _unreadCount = 0;
  List<NotificationData> _notifications = [];

  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;
  List<NotificationData> get notifications => List.unmodifiable(_notifications);

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.fetchNotifications();

    switch (result) {
      case ClientNotificationsFetchSuccess(:final model):
        _notifications = model.data ?? [];
        _unreadCount = model.unreadCount;
      case ClientNotificationsFetchFailure():
        break;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAllRead() async {
    final result = await _service.markNotificationsRead();

    switch (result) {
      case ClientNotificationsMarkReadSuccess():
        _unreadCount = 0;
        _notifications = _notifications
            .map(
              (n) => NotificationData(
                notificationId: n.notificationId,
                userId: n.userId,
                contextClientId: n.contextClientId,
                title: n.title,
                message: n.message,
                image: n.image,
                redirectUrl: n.redirectUrl,
                isRead: '1',
                createdBy: n.createdBy,
                createdAt: n.createdAt,
                updatedBy: n.updatedBy,
                updatedAt: n.updatedAt,
              ),
            )
            .toList();
        notifyListeners();
        return true;
      case ClientNotificationsMarkReadFailure():
        return false;
    }
  }
}
