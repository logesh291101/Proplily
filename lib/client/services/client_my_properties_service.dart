import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientPropertiesFetchResult {
  const ClientPropertiesFetchResult();
}

final class ClientPropertiesFetchSuccess extends ClientPropertiesFetchResult {
  const ClientPropertiesFetchSuccess(this.model);

  final ClientPropertiesModel model;
}

final class ClientPropertiesFetchFailure extends ClientPropertiesFetchResult {
  const ClientPropertiesFetchFailure({required this.message});

  final String message;
}

/// Fetches user properties from `GET {live_url}/user/properties`.
class ClientMyPropertiesService {
  ClientMyPropertiesService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientPropertiesFetchResult> fetchProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientPropertiesFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientPropertiesFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildUri(base);
    if (uri == null) {
      return const ClientPropertiesFetchFailure(
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
        return const ClientPropertiesFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientPropertiesFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientPropertiesFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientPropertiesFetchFailure(
        message: 'Could not read properties. Please try again.',
      );
    } catch (e) {
      return ClientPropertiesFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildUri(String base) {
    final uri = Uri.tryParse('$base/user/properties');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  ClientPropertiesFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientPropertiesFetchFailure(
        message: 'Properties response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);

    final ClientPropertiesModel model;
    if (decoded is List) {
      model = ClientPropertiesModel(
        status: true,
        message: '',
        data: _parsePropertyList(decoded),
        errors: null,
      );
    } else if (decoded is Map) {
      model = ClientPropertiesModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } else {
      return const ClientPropertiesFetchFailure(
        message: 'Invalid properties response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientPropertiesFetchFailure(message: apiError);
    }

    if (model.status != true) {
      final msg = model.message?.trim() ?? '';
      return ClientPropertiesFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load properties.',
      );
    }

    return ClientPropertiesFetchSuccess(model);
  }

  static List<ClientProperty> _parsePropertyList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map(_mapFromDynamic)
          .whereType<Map<String, dynamic>>()
          .map(ClientProperty.fromJson)
          .toList();
    }

    if (raw is Map) {
      final map = _mapFromDynamic(raw);
      if (map == null) return [];
      return [ClientProperty.fromJson(map)];
    }

    return [];
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
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
