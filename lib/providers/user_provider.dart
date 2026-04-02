import 'package:flutter/foundation.dart';
import '../models/user_dashboard_model.dart';
import '../models/notification_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  
  UserDashboard? _dashboard;
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  UserDashboard? get dashboard => _dashboard;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();
    _dashboard = await _userService.getDashboard();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNotifications() async {
    _notifications = await _userService.getNotifications();
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? password,
  }) async {
    final success = await _userService.updateProfile(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    if (success) {
      // Refresh user context if needed
    }
    return success;
  }
}
