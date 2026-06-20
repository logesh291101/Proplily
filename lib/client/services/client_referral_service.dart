import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/client/models/client_referral_code_model.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
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

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientReferralCodeFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

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
    required String name,
    required String email,
    required String countryCode,
    required String phone,
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

    final uri = _buildReferralSubmitUri(base);
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
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'country_code': countryCode,
          'phone': phone,
        }),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientReferralSubmitFailure(
          message: SessionExpiryHandler.message,
        );
      }

      final parsed = _tryParseJsonObject(response.body);
      if (parsed == null) {
        return const ClientReferralSubmitFailure(message: null);
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ClientReferralSubmitFailure(message: errorsText);
      }

      final messageText = _readStringLike(parsed['message']);
      if (_isSubmitSuccess(parsed)) {
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

  bool _isSubmitSuccess(Map<String, dynamic> json) {
    final apiStatus = json['status'];
    if (apiStatus is bool) return apiStatus;
    if (apiStatus is int) return apiStatus == 200 || apiStatus == 1;
    if (apiStatus is num) return apiStatus == 200 || apiStatus == 1;
    if (apiStatus is String) {
      final t = apiStatus.trim().toLowerCase();
      return t == '200' || t == 'true' || t == '1';
    }
    return false;
  }

  Uri? _buildReferFriendUri(String base) {
    final uri = Uri.tryParse('$base/user/refer-friend');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  Uri? _buildReferralSubmitUri(String base) {
    final uri = Uri.tryParse('$base/user/referrals/submit');
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
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
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
