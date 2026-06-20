import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/client/models/client_property_status_model.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class PropertyStatusFetchResult {
  const PropertyStatusFetchResult();
}

final class PropertyStatusFetchSuccess extends PropertyStatusFetchResult {
  const PropertyStatusFetchSuccess(this.model);

  final ClientPropertyStatusModel model;
}

final class PropertyStatusFetchFailure extends PropertyStatusFetchResult {
  const PropertyStatusFetchFailure({required this.message});

  final String message;
}

/// Fetches property status list from `GET {live_url}/user/properties/status`.
class PropertyStatusService {
  PropertyStatusService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<PropertyStatusFetchResult> fetchPropertyStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const PropertyStatusFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const PropertyStatusFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildUri(base);
    if (uri == null) {
      return const PropertyStatusFetchFailure(
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
        return const PropertyStatusFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return PropertyStatusFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const PropertyStatusFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const PropertyStatusFetchFailure(
        message: 'Could not read property status. Please try again.',
      );
    } catch (e) {
      return PropertyStatusFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildUri(String base) {
    final uri = Uri.tryParse('$base/user/properties/status');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  PropertyStatusFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const PropertyStatusFetchFailure(
        message: 'Property status response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);

    final ClientPropertyStatusModel model;
    if (decoded is List) {
      model = ClientPropertyStatusModel(
        status: true,
        message: '',
        data: ClientPropertyStatusModel.parsePropertyStatusList(decoded),
        errors: null,
      );
    } else if (decoded is Map) {
      model = ClientPropertyStatusModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } else {
      return const PropertyStatusFetchFailure(
        message: 'Invalid property status response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return PropertyStatusFetchFailure(message: apiError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return PropertyStatusFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load property status.',
      );
    }

    return PropertyStatusFetchSuccess(model);
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
        return apiMessage ?? 'Property status not found.';
      case 500:
      case 502:
      case 503:
        return apiMessage ??
            'Server error. Please try again in a few moments.';
      default:
        if (statusCode >= 500) {
          return apiMessage ?? 'Server error ($statusCode).';
        }
        return apiMessage ?? 'Could not load property status ($statusCode).';
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
