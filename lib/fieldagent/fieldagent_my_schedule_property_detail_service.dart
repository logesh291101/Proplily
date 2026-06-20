import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/fieldagent/my_schedule_property_detail_model.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class MySchedulePropertyDetailFetchResult {
  const MySchedulePropertyDetailFetchResult();
}

final class MySchedulePropertyDetailFetchSuccess
    extends MySchedulePropertyDetailFetchResult {
  const MySchedulePropertyDetailFetchSuccess(this.model);

  final MySchedulePropertyDetailModel model;
}

final class MySchedulePropertyDetailFetchFailure
    extends MySchedulePropertyDetailFetchResult {
  const MySchedulePropertyDetailFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Fetches schedule property detail from
/// `GET {live_url}/coordinator_api/tasks/{task_id}`.
class FieldAgentMySchedulePropertyDetailService {
  FieldAgentMySchedulePropertyDetailService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<MySchedulePropertyDetailFetchResult> fetchTaskDetail(
    String taskId,
  ) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Task ID is missing.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildTaskDetailUri(base, trimmedTaskId);
    if (uri == null) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Invalid server URL configuration.',
      );
    }

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
        return const MySchedulePropertyDetailFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return MySchedulePropertyDetailFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Could not read property details. Please try again.',
      );
    } catch (e) {
      return MySchedulePropertyDetailFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildTaskDetailUri(String base, String taskId) {
    final uri = Uri.tryParse('$base/coordinator_api/tasks/$taskId');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  MySchedulePropertyDetailFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Property details are empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const MySchedulePropertyDetailFetchFailure(
        message: 'Invalid property detail response.',
      );
    }

    final model = MySchedulePropertyDetailModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return MySchedulePropertyDetailFetchFailure(message: apiError);
    }

    if (!model.isSuccess || model.data == null) {
      final msg = model.message?.trim() ?? '';
      return MySchedulePropertyDetailFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load property details.',
      );
    }

    return MySchedulePropertyDetailFetchSuccess(model);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _readStringLike(parsed?['message']) ??
        _readErrorsText(parsed?['errors']);

    switch (statusCode) {
      case 401:
      case 403:
        return apiMessage ?? 'Unauthorized. Please sign in again.';
      case 404:
        return apiMessage ?? 'Property details not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load property details ($statusCode).';
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
