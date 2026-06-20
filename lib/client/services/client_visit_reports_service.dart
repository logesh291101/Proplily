import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_report_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientVisitReportsFetchResult {
  const ClientVisitReportsFetchResult();
}

final class ClientVisitReportsFetchSuccess extends ClientVisitReportsFetchResult {
  const ClientVisitReportsFetchSuccess(this.model);

  final ClientReportModel model;
}

final class ClientVisitReportsFetchFailure extends ClientVisitReportsFetchResult {
  const ClientVisitReportsFetchFailure({required this.message});

  final String message;
}

/// Fetches visit reports from `GET {live_url}/user/visit-reports`.
class ClientVisitReportsService {
  ClientVisitReportsService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientVisitReportsFetchResult> fetchVisitReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientVisitReportsFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientVisitReportsFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/visit-reports');
    if (uri == null || !uri.hasScheme) {
      return const ClientVisitReportsFetchFailure(
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
        return const ClientVisitReportsFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientVisitReportsFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientVisitReportsFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientVisitReportsFetchFailure(
        message: 'Could not read visit reports. Please try again.',
      );
    } catch (e) {
      return ClientVisitReportsFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientVisitReportsFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientVisitReportsFetchFailure(
        message: 'Visit reports response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    final ClientReportModel model;

    if (decoded is List) {
      model = ClientReportModel(
        status: true,
        message: '',
        data: _parseReportList(decoded),
        errors: null,
      );
    } else if (decoded is Map) {
      model = ClientReportModel.fromJson(Map<String, dynamic>.from(decoded));
    } else {
      return const ClientVisitReportsFetchFailure(
        message: 'Invalid visit reports response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientVisitReportsFetchFailure(message: apiError);
    }

    if (model.status != true) {
      final msg = model.message?.trim() ?? '';
      return ClientVisitReportsFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load visit reports.',
      );
    }

    return ClientVisitReportsFetchSuccess(model);
  }

  static List<ClientReportData> _parseReportList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => ClientReportData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map) {
      return [ClientReportData.fromJson(Map<String, dynamic>.from(raw))];
    }

    return [];
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
        return apiMessage ?? 'Visit reports not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load visit reports ($statusCode).';
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
