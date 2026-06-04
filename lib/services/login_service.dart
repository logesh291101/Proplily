import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:proplilly/services/auth_preferences.dart';
import 'package:proplilly/services/remote_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of calling [LoginService.login].
sealed class LoginResult {
  const LoginResult();
}

/// API login succeeded — user data stored in [SharedPreferences].
final class LoginSuccess extends LoginResult {
  const LoginSuccess({this.message});

  final String? message;
}

/// API login failed — UI shows [message] from the API `error` field when present.
final class LoginFailure extends LoginResult {
  const LoginFailure({this.message});

  final String? message;
}

/// POST login using base URL from SharedPreferences key [RemoteConfigKeys.liveUrl].
class LoginService {
  LoginService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  static const String _validationFailedMarker = 'Validation Failed';

  /// Calls `POST {live_url}/api/login` with JSON body `{ "email", "password" }`.
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final liveUrl =
        prefs.getString(RemoteConfigKeys.liveUrl)?.trim() ?? '';

    if (liveUrl.isEmpty) {
      return const LoginFailure();
    }

    final uri = _buildLoginUri(liveUrl);
    if (uri == null) {
      return const LoginFailure();
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
          'password': password,
        }),
      );

      if (kDebugMode) {
        developer.log(
          'status=${response.statusCode} body=${response.body}',
          name: 'LoginService',
        );
      }

      final parsed = _tryParseJsonObject(response.body);
      if (parsed == null) {
        return const LoginFailure();
      }

      if (_isLoginSuccess(parsed, response.statusCode)) {
        final stored = await _persistLoginData(prefs, parsed);
        if (!stored) {
          return const LoginFailure(
            message:
                'Login succeeded but could not save your account. Please try again.',
          );
        }
        return LoginSuccess(message: _readMessageField(parsed));
      }

      return LoginFailure(
        message: _readFailureMessage(parsed),
      );
    } on http.ClientException {
      return const LoginFailure();
    } on FormatException {
      return const LoginFailure();
    } catch (_) {
      return const LoginFailure();
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  /// Persists `data.token` and `data.user` fields from a successful login body.
  Future<bool> _persistLoginData(
    SharedPreferences prefs,
    Map<String, dynamic> json,
  ) async {
    final data = json['data'];
    if (data is! Map) return false;

    final dataMap = Map<String, dynamic>.from(data);
    final token = _readPersistableValue(dataMap['token']);
    if (token == null) return false;

    final user = dataMap['user'];
    if (user is! Map) return false;
    final userMap = Map<String, dynamic>.from(user);

    final userId = _readPersistableValue(userMap['id']);
    final email = _readPersistableValue(userMap['email']);
    final role = _readPersistableValue(userMap['role']);
    final userType = _readPersistableValue(userMap['user_type']);
    final name = _readPersistableValue(userMap['name']);

    if (userId == null ||
        email == null ||
        role == null ||
        userType == null ||
        name == null) {
      return false;
    }

    final results = await Future.wait<bool>([
      prefs.setString(AuthPreferenceKeys.token, token),
      prefs.setString(AuthPreferenceKeys.userId, userId),
      prefs.setString(AuthPreferenceKeys.email, email),
      prefs.setString(AuthPreferenceKeys.role, role),
      prefs.setString(AuthPreferenceKeys.userType, userType),
      prefs.setString(AuthPreferenceKeys.name, name),
    ]);

    return results.every((ok) => ok);
  }

  String? _readPersistableValue(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (raw is num || raw is bool) {
      return raw.toString();
    }
    return null;
  }

  bool _isLoginSuccess(Map<String, dynamic> json, int httpStatusCode) {
    if (_readTopLevelError(json) != null) return false;
    if (_messageIndicatesValidationFailure(json)) return false;

    final apiStatus = json['status'];
    if (apiStatus is int && apiStatus == 200) return true;
    if (apiStatus is num && apiStatus == 200) return true;
    if (apiStatus is bool && apiStatus) return true;
    if (apiStatus is String) {
      final t = apiStatus.trim();
      if (t == '200' || t.toLowerCase() == 'true') return true;
    }

    if (httpStatusCode == 200 && _readMessageField(json) != null) {
      return true;
    }

    return false;
  }

  Uri? _buildLoginUri(String liveUrl) {
    final trimmed = liveUrl.trim();
    if (trimmed.isEmpty) return null;

    var base = trimmed;
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }

    final uri = Uri.tryParse('$base/api/login');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  Map<String, dynamic>? _tryParseJsonObject(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _messageIndicatesValidationFailure(Map<String, dynamic> json) {
    final message = _readMessageField(json);
    if (message == null) return false;
    return message.contains(_validationFailedMarker);
  }

  String? _readTopLevelError(Map<String, dynamic> body) {
    return _readStringLike(body['error']);
  }

  String? _readFailureMessage(Map<String, dynamic> body) {
    final topError = _readTopLevelError(body);
    if (topError != null) return topError;

    final fromErrors = _readErrorsValue(body['errors']);
    if (fromErrors != null) return fromErrors;

    final messages = body['messages'];
    if (messages is Map) {
      final map = Map<String, dynamic>.from(messages);
      for (final key in ['error', 'email', 'password', 'message', 'login']) {
        final value = _readStringLike(map[key]);
        if (value != null) return value;
      }
      for (final value in map.values) {
        final text = _readStringLike(value);
        if (text != null) return text;
      }
    }

    return null;
  }

  String? _readErrorsValue(dynamic raw) {
    final direct = _readStringLike(raw);
    if (direct != null) return direct;

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      for (final key in ['error', 'email', 'password', 'message']) {
        final value = _readStringLike(map[key]);
        if (value != null) return value;
      }
      for (final value in map.values) {
        final text = _readStringLike(value);
        if (text != null) return text;
      }
    }

    return null;
  }

  String? _readStringLike(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      if (raw.trim().isEmpty) return null;
      return raw;
    }
    if (raw is List && raw.isNotEmpty) {
      return _readStringLike(raw.first);
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      for (final key in ['message', 'error', 'msg']) {
        final value = _readStringLike(map[key]);
        if (value != null) return value;
      }
    }
    return null;
  }

  String? _readMessageField(Map<String, dynamic> body) {
    return _readStringLike(body['message']);
  }
}
