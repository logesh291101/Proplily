import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      _setErrorMessage(null);
      final success = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      notifyListeners();
      return success;
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _setErrorMessage(null);
      final success = await _authService.signUp(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,

      );
      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final success = await _authService.verifyOTP(email: email, otp: otp);
    notifyListeners();
    return success;
  }

  Future<bool> login({
    required String email,
    required String password,
    UserType? userType,
  }) async {
    try {
      _setErrorMessage(null);
      final success = await _authService.login(
        email: email,
        password: password,
      );

      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setErrorMessage(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    return await _authService.forgotPassword(email);
  }

  Future<bool> resendOTP(String email) async {
    return await _authService.resendOTP(email);
  }

  Future<bool> resetPassword(String email, String password) async {
    return await _authService.resetPassword(email, password);
  }

  Future<User?> getProfile() async {
    final user = await _authService.getProfile();
    if (user != null) {
      notifyListeners();
    }
    return user;
  }

  Future<bool> loadAuthData() async {
    final success = await _authService.loadAuthData();
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
