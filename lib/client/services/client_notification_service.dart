import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_notification_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientNotificationsFetchResult {
  const ClientNotificationsFetchResult();
}

final class ClientNotificationsFetchSuccess extends ClientNotificationsFetchResult {
  const ClientNotificationsFetchSuccess(this.model);

  final ClientNotificationModel model;
}

final class ClientNotificationsFetchFailure extends ClientNotificationsFetchResult {
  const ClientNotificationsFetchFailure({required this.message});

  final String message;
}

sealed class ClientNotificationsMarkReadResult {
  const ClientNotificationsMarkReadResult();
}

final class ClientNotificationsMarkReadSuccess
    extends ClientNotificationsMarkReadResult {
  const ClientNotificationsMarkReadSuccess({this.message});

  final String? message;
}

final class ClientNotificationsMarkReadFailure
    extends ClientNotificationsMarkReadResult {
  const ClientNotificationsMarkReadFailure({required this.message});

  final String message;
}

/// Notifications API for the Client module.
class ClientNotificationService {
  ClientNotificationService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientNotificationsFetchResult> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientNotificationsFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientNotificationsFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/notifications');
    if (uri == null || !uri.hasScheme) {
      return const ClientNotificationsFetchFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    return _getJson(
      uri: uri,
      token: token,
      onSuccess: _parseNotificationsBody,
      failurePrefix: 'Could not load notifications',
    );
  }

  Future<ClientNotificationsMarkReadResult> markNotificationsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientNotificationsMarkReadFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientNotificationsMarkReadFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/notifications/mark-read');
    if (uri == null || !uri.hasScheme) {
      return const ClientNotificationsMarkReadFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientNotificationsMarkReadFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseMarkReadBody(response.body);
      }

      return ClientNotificationsMarkReadFailure(
        message: _messageForStatus(
          response.statusCode,
          response.body,
          'Could not mark notifications as read',
        ),
      );
    } on http.ClientException {
      return const ClientNotificationsMarkReadFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } catch (e) {
      return ClientNotificationsMarkReadFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<ClientNotificationsFetchResult> _getJson({
    required Uri uri,
    required String token,
    required ClientNotificationsFetchResult Function(String body) onSuccess,
    required String failurePrefix,
  }) async {
    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientNotificationsFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return onSuccess(response.body);
      }

      return ClientNotificationsFetchFailure(
        message: _messageForStatus(
          response.statusCode,
          response.body,
          failurePrefix,
        ),
      );
    } on http.ClientException {
      return const ClientNotificationsFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return ClientNotificationsFetchFailure(
        message: '$failurePrefix. Please try again.',
      );
    } catch (e) {
      return ClientNotificationsFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientNotificationsFetchResult _parseNotificationsBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientNotificationsFetchFailure(
        message: 'Notifications response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    final ClientNotificationModel model;

    if (decoded is List) {
      model = ClientNotificationModel(
        status: true,
        message: '',
        data: decoded
            .whereType<Map>()
            .map(
              (e) => NotificationData.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
    } else if (decoded is Map) {
      model = ClientNotificationModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } else {
      return const ClientNotificationsFetchFailure(
        message: 'Invalid notifications response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientNotificationsFetchFailure(message: apiError);
    }

    if (model.isSuccess == false) {
      final msg = model.message?.trim() ?? '';
      return ClientNotificationsFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load notifications.',
      );
    }

    return ClientNotificationsFetchSuccess(model);
  }

  ClientNotificationsMarkReadResult _parseMarkReadBody(String body) {
    final parsed = _tryParseJsonObject(body);
    final apiError = _readErrorsText(parsed?['errors']);
    if (apiError != null) {
      return ClientNotificationsMarkReadFailure(message: apiError);
    }

    final status = parsed?['status'];
    final isSuccess = status == true ||
        status == 200 ||
        status?.toString() == '200' ||
        status?.toString().toLowerCase() == 'true';

    if (parsed != null && !isSuccess && status != null) {
      final msg = _readStringLike(parsed['message']);
      return ClientNotificationsMarkReadFailure(
        message: msg ?? 'Could not mark notifications as read.',
      );
    }

    return ClientNotificationsMarkReadSuccess(
      message: _readStringLike(parsed?['message']),
    );
  }

  String _messageForStatus(int statusCode, String body, String fallback) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _readStringLike(parsed?['message']) ??
        _readErrorsText(parsed?['errors']);

    switch (statusCode) {
      case 401:
      case 403:
        return apiMessage ?? 'Unauthorized. Please sign in again.';
      case 404:
        return apiMessage ?? '$fallback not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ?? 'Server error. Please try again in a few moments.';
      default:
        return apiMessage ?? '$fallback ($statusCode).';
    }
  }

  Map<String, dynamic>? _tryParseJsonObject(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _readErrorsText(dynamic rawErrors) {
    if (rawErrors == null) return null;

    if (rawErrors is Map) {
      for (final v in rawErrors.values) {
        final text = _readStringLike(v);
        if (text != null) return text;
      }
      return null;
    }

    return _readStringLike(rawErrors);
  }

  String? _readStringLike(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }
    if (raw is List && raw.isNotEmpty) {
      return _readStringLike(raw.first);
    }
    return null;
  }
}
