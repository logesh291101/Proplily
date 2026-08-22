import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/fieldagent/fieldagent_referral_list_model.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentReferralListFetchResult {
  const FieldAgentReferralListFetchResult();
}

final class FieldAgentReferralListFetchSuccess
    extends FieldAgentReferralListFetchResult {
  const FieldAgentReferralListFetchSuccess(this.model);

  final FieldAgentReferralListModel model;
}

final class FieldAgentReferralListFetchFailure
    extends FieldAgentReferralListFetchResult {
  const FieldAgentReferralListFetchFailure({required this.message});

  final String message;
}

/// Fetches referrals from `GET {live_url}/coordinator_api/referrals`.
class FieldAgentReferralListService {
  FieldAgentReferralListService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<FieldAgentReferralListFetchResult> fetchReferrals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentReferralListFetchFailure(message: '');
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentReferralListFetchFailure(message: '');
    }

    final uri = Uri.tryParse('$base/coordinator_api/referrals');
    if (uri == null || !uri.hasScheme) {
      return const FieldAgentReferralListFetchFailure(message: '');
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
        return const FieldAgentReferralListFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return FieldAgentReferralListFetchFailure(
        message: _readApiMessage(response.body),
      );
    } on http.ClientException {
      return const FieldAgentReferralListFetchFailure(message: '');
    } on FormatException {
      return const FieldAgentReferralListFetchFailure(message: '');
    } catch (_) {
      return const FieldAgentReferralListFetchFailure(message: '');
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  FieldAgentReferralListFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const FieldAgentReferralListFetchFailure(message: '');
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map) {
      return const FieldAgentReferralListFetchFailure(message: '');
    }

    final model = FieldAgentReferralListModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return FieldAgentReferralListFetchFailure(message: apiError);
    }

    if (!model.status) {
      return FieldAgentReferralListFetchFailure(
        message: _combinedApiMessage(model.message, model.errors),
      );
    }

    return FieldAgentReferralListFetchSuccess(model);
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
