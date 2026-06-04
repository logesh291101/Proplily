import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/services/live_url_api.dart';

sealed class ResetPasswordResult {
  const ResetPasswordResult();
}

final class ResetPasswordSuccess extends ResetPasswordResult {
  const ResetPasswordSuccess({this.message});

  final String? message;
}

final class ResetPasswordFailure extends ResetPasswordResult {
  const ResetPasswordFailure({this.message});

  final String? message;
}

/// POST `{live_url}/api/reset-password` with email, otp, password, confirm_password.
class ResetPasswordService {
  ResetPasswordService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ResetPasswordResult> reset({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ResetPasswordFailure(message: null);
    }

    final uri = LiveUrlApi.endpoint(base, 'reset-password');
    if (uri == null) {
      return const ResetPasswordFailure(message: null);
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
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'confirm_password': confirmPassword,
        }),
      );

      final parsed = _tryParseJson(response.body);
      if (parsed == null) {
        return const ResetPasswordFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ResetPasswordFailure(message: errorsText);
      }

      final messageText = _readMessageText(parsed);
      if (_isResetPasswordSuccess(parsed, response.statusCode)) {
        return ResetPasswordSuccess(message: messageText);
      }

      return ResetPasswordFailure(message: messageText);
    } on http.ClientException {
      return const ResetPasswordFailure(message: null);
    } catch (_) {
      return const ResetPasswordFailure(message: null);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  bool _isResetPasswordSuccess(Map<String, dynamic> json, int httpStatusCode) {
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
      for (final key in [
        'otp',
        'email',
        'password',
        'confirm_password',
        'message',
      ]) {
        final text = _readStringLike(map[key]);
        if (text != null) return text;
      }
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
