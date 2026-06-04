import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/services/live_url_api.dart';

sealed class ForgotPasswordResult {
  const ForgotPasswordResult();
}

final class ForgotPasswordSuccess extends ForgotPasswordResult {
  const ForgotPasswordSuccess({this.message});

  final String? message;
}

final class ForgotPasswordFailure extends ForgotPasswordResult {
  const ForgotPasswordFailure({this.message});

  final String? message;
}

/// POST `{live_url}/api/forgot-password` with `{ "email": "..." }`.
class ForgotPasswordService {
  ForgotPasswordService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ForgotPasswordResult> sendOtp({required String email}) async {
    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ForgotPasswordFailure(message: null);
    }

    final uri = LiveUrlApi.endpoint(base, 'forgot-password');
    if (uri == null) {
      return const ForgotPasswordFailure(message: null);
    }

    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final parsed = _tryParseJson(response.body);
      if (parsed == null) {
        return const ForgotPasswordFailure(message: null);
      }

      // 1) errors has priority over message (exact value only).
      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ForgotPasswordFailure(message: errorsText);
      }

      // 2) If errors is null, success when API/body indicates success.
      final messageText = _readMessageText(parsed);
      if (_isForgotPasswordSuccess(parsed, response.statusCode)) {
        return ForgotPasswordSuccess(message: messageText);
      }

      return ForgotPasswordFailure(message: messageText);
    } on http.ClientException {
      return const ForgotPasswordFailure(message: null);
    } catch (_) {
      return const ForgotPasswordFailure(message: null);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  bool _isForgotPasswordSuccess(Map<String, dynamic> json, int httpStatusCode) {
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
      final emailText = _readStringLike(map['email']);
      if (emailText != null) return emailText;

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
