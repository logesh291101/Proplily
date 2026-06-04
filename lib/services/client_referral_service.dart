import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/models/referalcode_model.dart';
import 'package:proplilly/services/auth_preferences.dart';
import 'package:proplilly/services/live_url_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientReferralCodeFetchResult {
  const ClientReferralCodeFetchResult();
}

final class ClientReferralCodeFetchSuccess extends ClientReferralCodeFetchResult {
  const ClientReferralCodeFetchSuccess(this.model);

  final ReferalcodeModel model;
}

final class ClientReferralCodeFetchFailure extends ClientReferralCodeFetchResult {
  const ClientReferralCodeFetchFailure({required this.message});

  final String message;
}

sealed class ClientReferralSubmitResult {
  const ClientReferralSubmitResult();
}

final class ClientReferralSubmitSuccess extends ClientReferralSubmitResult {
  const ClientReferralSubmitSuccess({this.message});

  final String? message;
}

final class ClientReferralSubmitFailure extends ClientReferralSubmitResult {
  const ClientReferralSubmitFailure({this.message});

  final String? message;
}

/// Client referral API: fetch code and submit friend referral.
class ClientReferralService {
  ClientReferralService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  /// GET `{live_url}/user/refer-friend` — returns referral code.
  Future<ClientReferralCodeFetchResult> fetchReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientReferralCodeFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientReferralCodeFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildReferFriendUri(base);
    if (uri == null) {
      return const ClientReferralCodeFetchFailure(
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

      if (response.statusCode == 200) {
        return _parseReferralCodeBody(response.body);
      }

      return ClientReferralCodeFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientReferralCodeFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientReferralCodeFetchFailure(
        message: 'Could not read referral data. Please try again.',
      );
    } catch (e) {
      return ClientReferralCodeFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<ClientReferralSubmitResult> submitReferral({
    required String fullName,
    required String email,
    required String countryDialCode,
    required String phoneNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientReferralSubmitFailure(message: null);
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientReferralSubmitFailure(message: null);
    }

    final uri = _buildReferFriendUri(base);
    if (uri == null) {
      return const ClientReferralSubmitFailure(message: null);
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
          'full_name': fullName,
          'email': email,
          'country_code': countryDialCode,
          'phone': phoneNumber,
        }),
      );

      final parsed = _tryParseJsonObject(response.body);
      if (parsed == null) {
        return const ClientReferralSubmitFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ClientReferralSubmitFailure(message: errorsText);
      }

      final messageText = _readStringLike(parsed['message']);
      if (_isApiSuccess(parsed, response.statusCode)) {
        return ClientReferralSubmitSuccess(message: messageText);
      }

      return ClientReferralSubmitFailure(message: messageText);
    } on http.ClientException {
      return const ClientReferralSubmitFailure(message: null);
    } catch (_) {
      return const ClientReferralSubmitFailure(message: null);
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientReferralCodeFetchResult _parseReferralCodeBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientReferralCodeFetchFailure(
        message: 'Referral data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const ClientReferralCodeFetchFailure(
        message: 'Invalid referral response.',
      );
    }

    final model = ReferalcodeModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientReferralCodeFetchFailure(message: apiError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return ClientReferralCodeFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load referral code.',
      );
    }

    return ClientReferralCodeFetchSuccess(model);
  }

  bool _isApiSuccess(Map<String, dynamic> json, int httpStatusCode) {
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

  Uri? _buildReferFriendUri(String base) {
    final uri = Uri.tryParse('$base/user/refer-friend');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
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
        return apiMessage ?? 'Referral data not found.';
      default:
        if (statusCode >= 500) {
          return apiMessage ??
              'Server error. Please try again in a few moments.';
        }
        return apiMessage ?? 'Could not load referral code ($statusCode).';
    }
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
