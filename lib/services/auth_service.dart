import 'dart:convert';
import 'dart:developer';
import '../utils/preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'base_api_service.dart';

class AuthService extends BaseApiService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _token;
  User? _currentUser;

  String? get token => _token;
  User? get currentUser => _currentUser;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'] as String, data['data']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
    final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
    final response = await post('${baseUrl}api/register', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    });

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    String userType = 'customer',
  }) async {
    return register(
      name: fullName,
      email: email,
      phone: phoneNumber,
      password: password,
    );
  }

  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api/verify-otp', {
        'email': email,
        'otp': otp,
      });

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api/forgot-password', {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resendOTP(String email) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api/resend-otp', {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String password) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api/reset-password', {
        'email': email,
        'password': password,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getProfile() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}api/profile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      await post('${baseUrl}api/logout', {});
    } catch (e) {
      // Ignore logout errors
    } finally {
      await Prefs.remove(AppConstants.tokenKey);
      await Prefs.remove(AppConstants.userKey);
      await Prefs.remove(AppConstants.isLoggedInKey);
      _token = null;
      _currentUser = null;
    }
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    _token = token;
    _currentUser = User.fromJson({
      'id': userData['id']?.toString() ?? '',
      'fullName': userData['name'] ?? userData['fullName'] ?? '',
      'email': userData['email'] ?? '',
      'phoneNumber': userData['phone'] ?? userData['phoneNumber'] ?? '',
      'userType': userData['role'] ?? userData['user_type'] ?? userData['userType'] ?? 'customer',
      'createdAt': userData['created_at'] ?? userData['createdAt'] ?? DateTime.now().toIso8601String(),
    });
    
    await Prefs.setString(AppConstants.tokenKey, token);
    await Prefs.setString(AppConstants.userKey, jsonEncode(_currentUser!.toJson()));
    await Prefs.setBool(AppConstants.isLoggedInKey, true);
    
    log("🔑 JWT Token stored in Preferences: ${token.substring(0, min(10, token.length))}...");
  }

  int min(int a, int b) => a < b ? a : b;

  Future<bool> loadAuthData() async {
    try {
      final token = Prefs.getString(AppConstants.tokenKey);
      final userJson = Prefs.getString(AppConstants.userKey);

      if (token != null && userJson != null) {
        _token = token;
        _currentUser = User.fromJson(jsonDecode(userJson));
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool get isLoggedIn => _token != null && _currentUser != null;
}
