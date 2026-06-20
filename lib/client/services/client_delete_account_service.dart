import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class DeleteAccountResult {
  const DeleteAccountResult();
}

final class DeleteAccountSuccess extends DeleteAccountResult {
  const DeleteAccountSuccess({required this.message});

  final String message;
}

final class DeleteAccountFailure extends DeleteAccountResult {
  const DeleteAccountFailure({required this.message});

  final String message;
}

/// Account deletion APIs for `POST /user/delete-account` and cancel.
class ClientDeleteAccountService {
  ClientDeleteAccountService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<DeleteAccountResult> deleteAccount() {
    return _postAction(
      path: '/user/delete-account',
      fallbackError: 'Unable to process account deletion request.',
    );
  }

  Future<DeleteAccountResult> cancelDeleteAccount() {
    return _postAction(
      path: '/user/cancel-delete-account',
      fallbackError: 'Unable to cancel account deletion.',
    );
  }

  Future<DeleteAccountResult> _postAction({
    required String path,
    required String fallbackError,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const DeleteAccountFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const DeleteAccountFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base$path');
    if (uri == null || !uri.hasScheme) {
      return const DeleteAccountFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.post(
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
        return const DeleteAccountFailure(
          message: SessionExpiryHandler.message,
        );
      }

      return _parseResponse(response.statusCode, response.body, fallbackError);
    } on http.ClientException {
      return const DeleteAccountFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return DeleteAccountFailure(message: fallbackError);
    } catch (e) {
      return DeleteAccountFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  DeleteAccountResult _parseResponse(
    int statusCode,
    String body,
    String fallbackError,
  ) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _messageFromBody(parsed) ??
        _readErrorsText(parsed?['errors']);

    if (parsed != null) {
      final status = _parseStatus(parsed['status']);
      if (status == true) {
        final message = apiMessage ?? fallbackError;
        return DeleteAccountSuccess(message: message);
      }
      if (status == false) {
        return DeleteAccountFailure(
          message: apiMessage ?? fallbackError,
        );
      }
    }

    if (statusCode == 200 || statusCode == 201) {
      return DeleteAccountSuccess(
        message: apiMessage ?? fallbackError,
      );
    }

    return DeleteAccountFailure(
      message: apiMessage ?? fallbackError,
    );
  }

  bool? _parseStatus(dynamic raw) {
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      if (t == '200' || t == 'true') return true;
      if (t == 'false') return false;
    }
    return null;
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

  String? _messageFromBody(Map<String, dynamic>? json) {
    if (json == null) return null;
    return _readStringLike(json['message']);
  }

  String? _readErrorsText(dynamic rawErrors) {
    if (rawErrors == null) return null;

    if (rawErrors is Map) {
      for (final v in rawErrors.values) {
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
