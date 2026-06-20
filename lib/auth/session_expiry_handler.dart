import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:proplilly/auth/login_screen.dart';
import 'package:proplilly/auth/logout_service.dart';
import 'package:proplilly/client/theme/app_colors.dart';
import 'package:proplilly/navigation/app_navigator.dart';

/// Clears session data and returns the user to [LoginScreen] when JWT expires.
abstract final class SessionExpiryHandler {
  static const String message = 'Session expired. Please login again.';

  static bool _isHandling = false;

  static bool isExpiredResponse({
    int? statusCode,
    String? body,
    Map<String, dynamic>? json,
  }) {
    if (statusCode == 401) return true;

    final parsed = json ?? _tryParseJsonObject(body);
    if (parsed == null) return false;

    final error = _readString(parsed['error']);
    final apiMessage = _readString(parsed['message']);

    if (error == 'Expired token') return true;
    if (apiMessage == 'Access denied') return true;

    return false;
  }

  static Future<void> handleSessionExpired([BuildContext? context]) async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      await LogoutService().logout();

      AppNavigator.rootNavigatorKey.currentState?.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );

      _showExpirySnackBar();
    } finally {
      _isHandling = false;
    }
  }

  static void _showExpirySnackBar() {
    AppNavigator.rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Map<String, dynamic>? _tryParseJsonObject(String? body) {
    final trimmed = body?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _readString(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return raw.toString().trim();
  }
}
