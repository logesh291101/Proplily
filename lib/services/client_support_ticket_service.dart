import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/services/auth_preferences.dart';
import 'package:proplilly/services/live_url_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientSupportTicketResult {
  const ClientSupportTicketResult();
}

final class ClientSupportTicketSuccess extends ClientSupportTicketResult {
  const ClientSupportTicketSuccess({this.message});

  final String? message;
}

final class ClientSupportTicketFailure extends ClientSupportTicketResult {
  const ClientSupportTicketFailure({this.message});

  final String? message;
}

/// POST `{live_url}/support/submit` with subject, category, and message.
class ClientSupportTicketService {
  ClientSupportTicketService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientSupportTicketResult> submitTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientSupportTicketFailure(message: null);
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientSupportTicketFailure(message: null);
    }

    final uri = _buildSubmitUri(base);
    if (uri == null) {
      return const ClientSupportTicketFailure(message: null);
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
          'subject': subject,
          'category': category,
          'message': message,
        }),
      );

      final parsed = _tryParseJson(response.body);
      if (parsed == null) {
        return const ClientSupportTicketFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ClientSupportTicketFailure(message: errorsText);
      }

      final messageText = _readMessageText(parsed);
      if (_isSubmitSuccess(parsed, response.statusCode)) {
        return ClientSupportTicketSuccess(message: messageText);
      }

      return ClientSupportTicketFailure(message: messageText);
    } on http.ClientException {
      return const ClientSupportTicketFailure(message: null);
    } catch (_) {
      return const ClientSupportTicketFailure(message: null);
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

    if (httpStatusCode == 200 && json['errors'] == null) {
      return true;
    }

    return false;
  }

  Uri? _buildSubmitUri(String base) {
    final uri = Uri.tryParse('$base/user/support/submit');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final d = jsonDecode(t);
      if (d is Map) {
        return Map<String, dynamic>.from(d);
      }
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
