import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proplilly/auth/session_expiry_handler.dart';

/// Shared API helpers used across Client, Field Agent, and other modules.
abstract final class ApiService {
  /// Returns `true` when the response indicates an expired session and logout
  /// navigation has been triggered.
  static Future<bool> handleSessionExpiryIfNeeded({
    BuildContext? context,
    required int statusCode,
    required String body,
    Map<String, dynamic>? json,
  }) async {
    if (!SessionExpiryHandler.isExpiredResponse(
      statusCode: statusCode,
      body: body,
      json: json,
    )) {
      return false;
    }

    await SessionExpiryHandler.handleSessionExpired(context);
    return true;
  }

  static Future<bool> handleSessionExpiryIfNeededForResponse(
    http.Response response, {
    BuildContext? context,
  }) {
    return handleSessionExpiryIfNeeded(
      context: context,
      statusCode: response.statusCode,
      body: response.body,
    );
  }
}
