import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_properties_detail_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientPropertyDetailFetchResult {
  const ClientPropertyDetailFetchResult();
}

final class ClientPropertyDetailFetchSuccess
    extends ClientPropertyDetailFetchResult {
  const ClientPropertyDetailFetchSuccess({
    required this.data,
    this.message = '',
  });

  final ClientPropertyDetailData data;
  final String message;
}

final class ClientPropertyDetailFetchFailure
    extends ClientPropertyDetailFetchResult {
  const ClientPropertyDetailFetchFailure({required this.message});

  final String message;
}

/// Fetches a single property from `GET {live_url}/user/properties/{property_id}`.
class ClientPropertyDetailService {
  ClientPropertyDetailService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientPropertyDetailFetchResult> fetchPropertyDetail(
    String propertyId,
  ) async {
    final trimmedId = propertyId.trim();
    if (trimmedId.isEmpty) {
      return const ClientPropertyDetailFetchFailure(
        message: 'Property ID is missing.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientPropertyDetailFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientPropertyDetailFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/properties/$trimmedId');
    if (uri == null || !uri.hasScheme) {
      return const ClientPropertyDetailFetchFailure(
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
        return const ClientPropertyDetailFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientPropertyDetailFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientPropertyDetailFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientPropertyDetailFetchFailure(
        message: 'Could not read property details. Please try again.',
      );
    } catch (e) {
      return ClientPropertyDetailFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientPropertyDetailFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientPropertyDetailFetchFailure(
        message: 'Property details response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      return const ClientPropertyDetailFetchFailure(
        message: 'Invalid property details response.',
      );
    }

    final map = Map<String, dynamic>.from(decoded);
    final apiError = _readErrorsText(map['errors']);
    if (apiError != null) {
      return ClientPropertyDetailFetchFailure(message: apiError);
    }

    final model = ClientPropertiesDetailModel.fromJson(map);
    final modelError = _readErrorsText(model.errors);
    if (modelError != null) {
      return ClientPropertyDetailFetchFailure(message: modelError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return ClientPropertyDetailFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load property details.',
      );
    }

    return ClientPropertyDetailFetchSuccess(
      data: model.data,
      message: model.message.trim(),
    );
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
        return apiMessage ?? 'Property not found.';
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
      for (final value in rawErrors.values) {
        final text = _readStringLike(value);
        if (text != null) return text;
      }
      return null;
    }

    return _readStringLike(rawErrors);
  }

  String? _readStringLike(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final text = raw.trim();
      return text.isEmpty ? null : text;
    }
    if (raw is List && raw.isNotEmpty) {
      return _readStringLike(raw.first);
    }
    return null;
  }
}
