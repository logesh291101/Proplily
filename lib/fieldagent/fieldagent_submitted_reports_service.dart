import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/fieldagent/fieldagent_submitted_report_model.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentSubmittedReportsFetchResult {
  const FieldAgentSubmittedReportsFetchResult();
}

final class FieldAgentSubmittedReportsFetchSuccess
    extends FieldAgentSubmittedReportsFetchResult {
  const FieldAgentSubmittedReportsFetchSuccess(this.model);

  final FieldAgentSubmittedReportModel model;
}

final class FieldAgentSubmittedReportsFetchFailure
    extends FieldAgentSubmittedReportsFetchResult {
  const FieldAgentSubmittedReportsFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Fetches submitted inspections from `GET {live_url}/coordinator_api/inspections`.
class FieldAgentSubmittedReportsService {
  FieldAgentSubmittedReportsService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<FieldAgentSubmittedReportsFetchResult> fetchReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildInspectionsUri(base);
    if (uri == null) {
      return const FieldAgentSubmittedReportsFetchFailure(
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
        return const FieldAgentSubmittedReportsFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return FieldAgentSubmittedReportsFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Could not read reports data. Please try again.',
      );
    } catch (e) {
      return FieldAgentSubmittedReportsFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildInspectionsUri(String base) {
    final uri = Uri.tryParse('$base/coordinator_api/inspections');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  FieldAgentSubmittedReportsFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Reports data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const FieldAgentSubmittedReportsFetchFailure(
        message: 'Invalid reports response.',
      );
    }

    final model = FieldAgentSubmittedReportModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return FieldAgentSubmittedReportsFetchFailure(message: apiError);
    }

    if (model.status != true) {
      final msg = model.message?.trim() ?? '';
      return FieldAgentSubmittedReportsFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load reports.',
      );
    }

    return FieldAgentSubmittedReportsFetchSuccess(model);
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
        return 'Reports not found.';
      default:
        return 'Could not load reports ($statusCode).';
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
