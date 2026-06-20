import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/client/models/client_feedback_history_model.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientFeedbackHistoryFetchResult {
  const ClientFeedbackHistoryFetchResult();
}

final class ClientFeedbackHistoryFetchSuccess
    extends ClientFeedbackHistoryFetchResult {
  const ClientFeedbackHistoryFetchSuccess(this.model);

  final ClientFeedbackHistoryModel model;
}

final class ClientFeedbackHistoryFetchFailure
    extends ClientFeedbackHistoryFetchResult {
  const ClientFeedbackHistoryFetchFailure({required this.message});

  final String message;
}

sealed class ClientFeedbackResult {
  const ClientFeedbackResult();
}

final class ClientFeedbackSuccess extends ClientFeedbackResult {
  const ClientFeedbackSuccess({this.message});

  final String? message;
}

final class ClientFeedbackFailure extends ClientFeedbackResult {
  const ClientFeedbackFailure({this.message});

  final String? message;
}

/// Client feedback submit and history APIs.
class ClientFeedbackService {
  ClientFeedbackService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  /// GET `{live_url}/user/feedback` — feedback history list.
  Future<ClientFeedbackHistoryFetchResult> fetchFeedbackHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildHistoryUri(base);
    if (uri == null) {
      return const ClientFeedbackHistoryFetchFailure(
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
        return const ClientFeedbackHistoryFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseHistorySuccessBody(response.body);
      }

      return ClientFeedbackHistoryFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Could not read feedback history. Please try again.',
      );
    } catch (e) {
      return ClientFeedbackHistoryFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<ClientFeedbackResult> submitFeedback({
    required int rating,
    required String feedbackMessage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientFeedbackFailure(message: null);
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientFeedbackFailure(message: null);
    }

    final uri = _buildSubmitUri(base);
    if (uri == null) {
      return const ClientFeedbackFailure(message: null);
    }

    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'feedback_message': feedbackMessage,
        }),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientFeedbackFailure(
          message: SessionExpiryHandler.message,
        );
      }

      final parsed = _tryParseJson(response.body);
      if (parsed == null) {
        return const ClientFeedbackFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ClientFeedbackFailure(message: errorsText);
      }

      final messageText = _readMessageText(parsed);
      if (_isSubmitSuccess(parsed, response.statusCode)) {
        return ClientFeedbackSuccess(message: messageText);
      }

      return ClientFeedbackFailure(message: messageText);
    } on http.ClientException {
      return const ClientFeedbackFailure(message: null);
    } catch (_) {
      return const ClientFeedbackFailure(message: null);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  bool _isSubmitSuccess(Map<String, dynamic> json, int httpStatusCode) {
    final apiStatus = json['status'];
    if (apiStatus is int && apiStatus == 200) return true;
    if (apiStatus is num && apiStatus == 200) return true;
    if (apiStatus is bool && apiStatus) return true;
    if (apiStatus is String) {
      final t = apiStatus.trim();
      if (t == '200' || t.toLowerCase() == 'true') return true;
    }

    if (httpStatusCode >= 200 && httpStatusCode < 300 && json['errors'] == null) {
      return true;
    }

    return false;
  }

  Uri? _buildSubmitUri(String base) {
    final uri = Uri.tryParse('$base/user/feedback/submit');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  Uri? _buildHistoryUri(String base) {
    final uri = Uri.tryParse('$base/user/feedback');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  ClientFeedbackHistoryFetchResult _parseHistorySuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Feedback history is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);

    final ClientFeedbackHistoryModel model;
    if (decoded is List) {
      model = ClientFeedbackHistoryModel(
        status: true,
        message: '',
        data: ClientFeedbackHistoryModel.parseFeedbackHistoryList(decoded),
        errors: null,
      );
    } else if (decoded is Map<String, dynamic>) {
      model = ClientFeedbackHistoryModel.fromJson(decoded);
    } else {
      return const ClientFeedbackHistoryFetchFailure(
        message: 'Invalid feedback history response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientFeedbackHistoryFetchFailure(message: apiError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return ClientFeedbackHistoryFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load feedback history.',
      );
    }

    return ClientFeedbackHistoryFetchSuccess(model);
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
        return apiMessage ?? 'Feedback history not found.';
      default:
        if (statusCode >= 500) {
          return apiMessage ??
              'Server error. Please try again in a few moments.';
        }
        return apiMessage ?? 'Could not load feedback history ($statusCode).';
    }
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    return _tryParseJsonObject(body);
  }

  Map<String, dynamic>? _tryParseJsonObject(String body) {
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final d = jsonDecode(t);
      if (d is Map<String, dynamic>) return d;
      if (d is Map) return Map<String, dynamic>.from(d);
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

  String? _readMessageText(Map<String, dynamic> parsed) {
    return _readStringLike(parsed['message']);
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
