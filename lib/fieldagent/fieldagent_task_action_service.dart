import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentTaskActionResult {
  const FieldAgentTaskActionResult();
}

final class FieldAgentTaskActionSuccess extends FieldAgentTaskActionResult {
  const FieldAgentTaskActionSuccess({this.message});

  final String? message;
}

final class FieldAgentTaskActionFailure extends FieldAgentTaskActionResult {
  const FieldAgentTaskActionFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Posts task actions to `POST {live_url}/coordinator_api/tasks/{task_id}/action`.
class FieldAgentTaskActionService {
  FieldAgentTaskActionService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<FieldAgentTaskActionResult> acceptTask(String taskId) {
    return _performAction(
      taskId: taskId,
      body: const {'action': 'accept'},
    );
  }

  Future<FieldAgentTaskActionResult> rejectTask({
    required String taskId,
    required String reason,
  }) {
    return _performAction(
      taskId: taskId,
      body: {
        'action': 'reject',
        'reason': reason.trim(),
      },
    );
  }

  Future<FieldAgentTaskActionResult> rescheduleTask({
    required String taskId,
    required String newDate,
    required String reason,
  }) {
    return _performAction(
      taskId: taskId,
      body: {
        'action': 'reschedule',
        'new_date': newDate.trim(),
        'reason': reason.trim(),
      },
    );
  }

  Future<FieldAgentTaskActionResult> _performAction({
    required String taskId,
    required Map<String, dynamic> body,
  }) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      return const FieldAgentTaskActionFailure(message: 'Task ID is missing.');
    }

    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentTaskActionFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentTaskActionFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildActionUri(base, trimmedTaskId);
    if (uri == null) {
      return const FieldAgentTaskActionFailure(
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
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const FieldAgentTaskActionFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseSuccessBody(response.body);
      }

      return FieldAgentTaskActionFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const FieldAgentTaskActionFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const FieldAgentTaskActionFailure(
        message: 'Could not read action response. Please try again.',
      );
    } catch (e) {
      return FieldAgentTaskActionFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildActionUri(String base, String taskId) {
    final uri = Uri.tryParse('$base/coordinator_api/tasks/$taskId/action');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  FieldAgentTaskActionResult _parseSuccessBody(String body) {
    final parsed = _tryParseJsonObject(body);
    if (parsed == null) {
      return const FieldAgentTaskActionSuccess(
        message: 'Action completed successfully.',
      );
    }

    final apiError = _readErrorsText(parsed['errors']);
    if (apiError != null) {
      return FieldAgentTaskActionFailure(message: apiError);
    }

    final status = parsed['status'];
    final isSuccess = status == true ||
        status == 200 ||
        status == '200' ||
        status == 'true';

    final message = _readStringLike(parsed['message']);

    if (!isSuccess && status != null) {
      return FieldAgentTaskActionFailure(
        message: message ?? 'Action failed.',
      );
    }

    return FieldAgentTaskActionSuccess(message: message);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _readStringLike(parsed?['message']) ??
        _readErrorsText(parsed?['errors']);

    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    switch (statusCode) {
      case 401:
      case 403:
        return 'Unauthorized. Please sign in again.';
      case 404:
        return 'Task action not found.';
      default:
        return 'Action failed ($statusCode).';
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
      final map = Map<String, dynamic>.from(rawErrors);
      for (final v in map.values) {
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
