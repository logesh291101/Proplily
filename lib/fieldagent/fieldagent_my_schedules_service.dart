import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentMySchedulesFetchResult {
  const FieldAgentMySchedulesFetchResult();
}

final class FieldAgentMySchedulesFetchSuccess
    extends FieldAgentMySchedulesFetchResult {
  const FieldAgentMySchedulesFetchSuccess(this.model);

  final FieldAgentMySchedulesModel model;
}

final class FieldAgentMySchedulesFetchFailure
    extends FieldAgentMySchedulesFetchResult {
  const FieldAgentMySchedulesFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Fetches assigned properties from `GET {live_url}/coordinator_api/properties`.
class FieldAgentMySchedulesService {
  FieldAgentMySchedulesService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<FieldAgentMySchedulesFetchResult> fetchProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildPropertiesUri(base);
    if (uri == null) {
      return const FieldAgentMySchedulesFetchFailure(
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
        return const FieldAgentMySchedulesFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return FieldAgentMySchedulesFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Could not read property data. Please try again.',
      );
    } catch (e) {
      return FieldAgentMySchedulesFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildPropertiesUri(String base) {
    final uri = Uri.tryParse('$base/coordinator_api/properties');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  FieldAgentMySchedulesFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Property data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const FieldAgentMySchedulesFetchFailure(
        message: 'Invalid property response.',
      );
    }

    final model = FieldAgentMySchedulesModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return FieldAgentMySchedulesFetchFailure(message: apiError);
    }

    if (!model.isSuccess) {
      final msg = model.message?.trim() ?? '';
      return FieldAgentMySchedulesFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load assigned properties.',
      );
    }

    return FieldAgentMySchedulesFetchSuccess(model);
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
        return apiMessage ?? 'Properties not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load properties ($statusCode).';
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
