import 'dart:convert';
import 'dart:io';

import '../models/user_dashboard_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../utils/preferences.dart';
import 'base_api_service.dart';
import 'admin_service.dart';

class UserService extends BaseApiService {
  Future<UserDashboard?> getDashboard() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/dashboard');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserDashboard.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> getProfile() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    File? profileImage,
    String? password,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      if (profileImage != null) {
        final response = await multipartPost(
          url: '${baseUrl}user/profile/update',
          fields: {
            'name': name,
            'email': email,
            'phone': phone,
            if (password != null) 'password': password,
          },
          files: [profileImage],
          fieldName: 'profile_image',
        );
        return response.statusCode == 200;
      } else {
        final response = await post('${baseUrl}user/profile/update', {
          'name': name,
          'email': email,
          'phone': phone,
          if (password != null) 'password': password,
        });
        return response.statusCode == 200;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/notifications');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((n) => NotificationModel.fromJson(n)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> markNotificationsRead() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}user/notifications/mark-read', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Compatibility methods
  Future<List<User>> getCustomers() async {
    return await AdminService().getUsers(status: 'customer');
  }

  Future<List<User>> getCoordinators() async {
    return await AdminService().getUsers(status: 'coordinator');
  }
}
