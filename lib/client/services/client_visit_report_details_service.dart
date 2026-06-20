import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_report_detail_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientVisitReportDetailFetchResult {
  const ClientVisitReportDetailFetchResult();
}

final class ClientVisitReportDetailFetchSuccess
    extends ClientVisitReportDetailFetchResult {
  const ClientVisitReportDetailFetchSuccess(this.model);

  final ClientReportDetailModel model;
}

final class ClientVisitReportDetailFetchFailure
    extends ClientVisitReportDetailFetchResult {
  const ClientVisitReportDetailFetchFailure({required this.message});

  final String message;
}

/// Fetches a visit report from `GET {live_url}/user/visit-reports/{report_id}`.
class ClientVisitReportDetailsService {
  ClientVisitReportDetailsService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientVisitReportDetailFetchResult> fetchReportDetails({
    required String reportId,
  }) async {
    final trimmedId = reportId.trim();
    if (trimmedId.isEmpty) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Report ID is missing.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/visit-reports/$trimmedId');
    if (uri == null || !uri.hasScheme) {
      return const ClientVisitReportDetailFetchFailure(
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
        return const ClientVisitReportDetailFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientVisitReportDetailFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Could not read report details. Please try again.',
      );
    } catch (e) {
      return ClientVisitReportDetailFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientVisitReportDetailFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Report details response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Invalid report details response.',
      );
    }

    final model = ClientReportDetailModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientVisitReportDetailFetchFailure(message: apiError);
    }

    if (model.status != true) {
      final msg = model.message?.trim() ?? '';
      return ClientVisitReportDetailFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load report details.',
      );
    }

    if (model.data == null) {
      return const ClientVisitReportDetailFetchFailure(
        message: 'Report details are unavailable.',
      );
    }

    return ClientVisitReportDetailFetchSuccess(model);
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
        return apiMessage ?? 'Report not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load report details ($statusCode).';
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
