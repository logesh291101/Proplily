import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_market_lines_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientMarketLinesFetchResult {
  const ClientMarketLinesFetchResult();
}

final class ClientMarketLinesFetchSuccess extends ClientMarketLinesFetchResult {
  const ClientMarketLinesFetchSuccess(this.model);

  final ClientMarketLinesModel model;
}

final class ClientMarketLinesFetchFailure extends ClientMarketLinesFetchResult {
  const ClientMarketLinesFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Fetches market headlines from `GET {live_url}/user/headlines`.
class ClientMarketLinesService {
  ClientMarketLinesService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientMarketLinesFetchResult> fetchHeadlines() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientMarketLinesFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientMarketLinesFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/headlines');
    if (uri == null || !uri.hasScheme) {
      return const ClientMarketLinesFetchFailure(
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
        return const ClientMarketLinesFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientMarketLinesFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const ClientMarketLinesFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientMarketLinesFetchFailure(
        message: 'Could not read market headlines. Please try again.',
      );
    } catch (e) {
      return ClientMarketLinesFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientMarketLinesFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientMarketLinesFetchFailure(
        message: 'Headlines data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const ClientMarketLinesFetchFailure(
        message: 'Invalid headlines response.',
      );
    }

    final model = ClientMarketLinesModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientMarketLinesFetchFailure(message: apiError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return ClientMarketLinesFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load market headlines.',
      );
    }

    return ClientMarketLinesFetchSuccess(model);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _messageFromBody(parsed) ??
        _readErrorsFromParsed(parsed);

    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    switch (statusCode) {
      case 401:
      case 403:
        return 'Unauthorized. Please sign in again.';
      case 404:
        return 'Market headlines not found.';
      default:
        if (statusCode >= 500) {
          return 'Server error. Please try again in a few moments.';
        }
        return 'Could not load market headlines ($statusCode).';
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

  String? _readErrorsFromParsed(Map<String, dynamic>? json) {
    if (json == null) return null;
    return _readErrorsText(json['errors']);
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
    return _readStringLike(json['message']);
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
