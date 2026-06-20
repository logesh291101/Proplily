import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class EditClientProfileResult {
  const EditClientProfileResult();
}

final class EditClientProfileSuccess extends EditClientProfileResult {
  const EditClientProfileSuccess({this.message});

  final String? message;
}

final class EditClientProfileFailure extends EditClientProfileResult {
  const EditClientProfileFailure({this.message});

  final String? message;
}

/// POST `{live_url}/user/profile/update` with name and phone.
class EditClientProfileService {
  EditClientProfileService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<EditClientProfileResult> updateProfile({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const EditClientProfileFailure(message: null);
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const EditClientProfileFailure(message: null);
    }

    final uri = _buildUpdateUri(base);
    if (uri == null) {
      return const EditClientProfileFailure(message: null);
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
          'name': name,
          'phone': phone,
        }),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const EditClientProfileFailure(
          message: SessionExpiryHandler.message,
        );
      }

      final parsed = _tryParseJson(response.body);
      if (parsed == null) {
        return const EditClientProfileFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return EditClientProfileFailure(message: errorsText);
      }

      final messageText = _readMessageText(parsed);
      if (_isUpdateSuccess(parsed, response.statusCode)) {
        await _persistNameIfPresent(prefs, name);
        return EditClientProfileSuccess(message: messageText);
      }

      return EditClientProfileFailure(message: messageText);
    } on http.ClientException {
      return const EditClientProfileFailure(message: null);
    } catch (_) {
      return const EditClientProfileFailure(message: null);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<void> _persistNameIfPresent(
    SharedPreferences prefs,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await prefs.setString(AuthPreferenceKeys.name, trimmed);
  }

  bool _isUpdateSuccess(Map<String, dynamic> json, int httpStatusCode) {
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

  Uri? _buildUpdateUri(String base) {
    final uri = Uri.tryParse('$base/user/profile/update');
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
