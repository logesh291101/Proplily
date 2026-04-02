class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final String? forUserId; // null means global or admin

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.forUserId,
  });
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<NotificationItem> _notifications = [];

  void addNotification(String title, String message, {String? forUserId}) {
    _notifications.insert(0, NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      forUserId: forUserId,
    ));
  }

  List<NotificationItem> getNotificationsForUser(String? userId, bool isAdmin) {
    if (isAdmin) {
      return _notifications.where((n) => n.forUserId == null || n.forUserId == userId).toList();
    }
    return _notifications.where((n) => n.forUserId == userId).toList();
  }

  int getUnreadCount(String? userId, bool isAdmin) {
    return getNotificationsForUser(userId, isAdmin).where((n) => !n.isRead).length;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
    }
  }

  void markAllAsReadForUser(String? userId, bool isAdmin) {
    final userNotifs = getNotificationsForUser(userId, isAdmin);
    for (var n in userNotifs) {
      n.isRead = true;
    }
  }
}
