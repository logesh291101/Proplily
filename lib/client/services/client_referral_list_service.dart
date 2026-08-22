import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_referral_list_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientReferralListFetchResult {
  const ClientReferralListFetchResult();
}

final class ClientReferralListFetchSuccess extends ClientReferralListFetchResult {
  const ClientReferralListFetchSuccess(this.model);

  final ClientReferralListModel model;
}

final class ClientReferralListFetchFailure extends ClientReferralListFetchResult {
  const ClientReferralListFetchFailure({required this.message});

  final String message;
}

/// Fetches referral list from `GET {live_url}/user/referrals`.
class ClientReferralListService {
  ClientReferralListService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientReferralListFetchResult> fetchReferrals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientReferralListFetchFailure(message: '');
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientReferralListFetchFailure(message: '');
    }

    final uri = Uri.tryParse('$base/user/referrals');
    if (uri == null || !uri.hasScheme) {
      return const ClientReferralListFetchFailure(message: '');
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
        return const ClientReferralListFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientReferralListFetchFailure(
        message: _readApiMessage(response.body),
      );
    } on http.ClientException {
      return const ClientReferralListFetchFailure(message: '');
    } on FormatException {
      return const ClientReferralListFetchFailure(message: '');
    } catch (_) {
      return const ClientReferralListFetchFailure(message: '');
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientReferralListFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientReferralListFetchFailure(message: '');
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      return const ClientReferralListFetchFailure(message: '');
    }

    final model = ClientReferralListModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientReferralListFetchFailure(message: apiError);
    }

    if (!model.status) {
      return ClientReferralListFetchFailure(
        message: _combinedApiMessage(model.message, model.errors),
      );
    }

    return ClientReferralListFetchSuccess(model);
  }

  String _readApiMessage(String body) {
    final parsed = _tryParseJsonObject(body);
    if (parsed == null) return '';

    return _combinedApiMessage(
      parsed['message']?.toString(),
      parsed['errors'],
    );
  }

  String _combinedApiMessage(dynamic message, dynamic errors) {
    final messageText = _readStringLike(message);
    if (messageText != null) return messageText;

    return _readErrorsText(errors) ?? '';
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
      for (final value in rawErrors.values) {
        final text = _readStringLike(value);
        if (text != null) return text;
      }
      return null;
    }

    return _readStringLike(rawErrors);
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
