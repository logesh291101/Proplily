import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => _authService.isLoggedIn;

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required UserType userType,
  }) async {
    final success = await _authService.signUp(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      userType: userType,
    );
    notifyListeners();
    return success;
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
    final success = await _authService.login(
      email: email, 
      password: password,
      userType: userType,
    );
    notifyListeners();
    return success;
  }

  Future<bool> forgotPassword(String email) async {
    return await _authService.forgotPassword(email);
  }

  Future<bool> resendOTP(String email) async {
    return await _authService.resendOTP(email);
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
