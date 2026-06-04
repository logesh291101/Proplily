import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/models/Model/clientDashboard_model.dart';
import 'package:proplilly/services/auth_preferences.dart';
import 'package:proplilly/services/live_url_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of [HomeService.fetchDashboard].
sealed class HomeDashboardFetchResult {
  const HomeDashboardFetchResult();
}

/// HTTP 200 with parsed [ClientDashboardModel].
final class HomeDashboardFetchSuccess extends HomeDashboardFetchResult {
  const HomeDashboardFetchSuccess(this.model);

  final ClientDashboardModel model;
}

/// Validation, network, or non-success HTTP response.
final class HomeDashboardFetchFailure extends HomeDashboardFetchResult {
  const HomeDashboardFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Fetches client dashboard from `GET {live_url}/user/dashboard`.
class HomeService {
  HomeService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<HomeDashboardFetchResult> fetchDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const HomeDashboardFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const HomeDashboardFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildDashboardUri(base);
    if (uri == null) {
      return const HomeDashboardFetchFailure(
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

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return HomeDashboardFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const HomeDashboardFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const HomeDashboardFetchFailure(
        message: 'Could not read dashboard data. Please try again.',
      );
    } catch (e) {
      return HomeDashboardFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildDashboardUri(String base) {
    final uri = Uri.tryParse('$base/user/dashboard');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  HomeDashboardFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const HomeDashboardFetchFailure(
        message: 'Dashboard data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const HomeDashboardFetchFailure(
        message: 'Invalid dashboard response.',
      );
    }

    final model = ClientDashboardModel.fromJson(decoded);
    if (!model.status) {
      final msg = model.message.trim();
      return HomeDashboardFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load dashboard.',
      );
    }

    return HomeDashboardFetchSuccess(model);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _messageFromBody(parsed);

    switch (statusCode) {
      case 401:
      case 403:
        return apiMessage ?? 'Unauthorized. Please sign in again.';
      case 404:
        return apiMessage ?? 'Dashboard not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load dashboard ($statusCode).';
    }
  }

  Map<String, dynamic>? _tryParseJsonObject(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _messageFromBody(Map<String, dynamic>? json) {
    if (json == null) return null;
    for (final key in ['message', 'error', 'detail', 'msg']) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}
