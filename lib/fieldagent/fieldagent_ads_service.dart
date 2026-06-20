import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/fieldagent/fieldagent_ads_model.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentAdsFetchResult {
  const FieldAgentAdsFetchResult();
}

final class FieldAgentAdsFetchSuccess extends FieldAgentAdsFetchResult {
  const FieldAgentAdsFetchSuccess(this.model);

  final FieldAgentAdsModel model;
}

final class FieldAgentAdsFetchFailure extends FieldAgentAdsFetchResult {
  const FieldAgentAdsFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

sealed class FieldAgentAdInterestResult {
  const FieldAgentAdInterestResult();
}

final class FieldAgentAdInterestSuccess extends FieldAgentAdInterestResult {
  const FieldAgentAdInterestSuccess({this.message});

  final String? message;
}

final class FieldAgentAdInterestFailure extends FieldAgentAdInterestResult {
  const FieldAgentAdInterestFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Ads API for Field Agent module.
class FieldAgentAdsService {
  FieldAgentAdsService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<FieldAgentAdsFetchResult> fetchAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentAdsFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentAdsFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/coordinator_api/ads');
    if (uri == null || !uri.hasScheme) {
      return const FieldAgentAdsFetchFailure(
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
        return const FieldAgentAdsFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseFetchSuccessBody(response.body);
      }

      return FieldAgentAdsFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const FieldAgentAdsFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const FieldAgentAdsFetchFailure(
        message: 'Could not read ads data. Please try again.',
      );
    } catch (e) {
      return FieldAgentAdsFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<FieldAgentAdInterestResult> submitInterest({
    required String adId,
    required String interestResponse,
    String? interestNotes,
  }) async {
    final trimmedAdId = adId.trim();
    if (trimmedAdId.isEmpty) {
      return const FieldAgentAdInterestFailure(message: 'Ad ID is missing.');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentAdInterestFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentAdInterestFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/coordinator_api/ads/interest');
    if (uri == null || !uri.hasScheme) {
      return const FieldAgentAdInterestFailure(
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
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ad_id': trimmedAdId,
          'interest_response': interestResponse.trim().toLowerCase(),
          'interest_notes': interestNotes?.trim() ?? '',
        }),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const FieldAgentAdInterestFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseInterestBody(response.body);
      }

      return FieldAgentAdInterestFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const FieldAgentAdInterestFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const FieldAgentAdInterestFailure(
        message: 'Could not read interest response. Please try again.',
      );
    } catch (e) {
      return FieldAgentAdInterestFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  FieldAgentAdsFetchResult _parseFetchSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const FieldAgentAdsFetchFailure(
        message: 'Ads data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const FieldAgentAdsFetchFailure(
        message: 'Invalid ads response.',
      );
    }

    final model = FieldAgentAdsModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return FieldAgentAdsFetchFailure(message: apiError);
    }

    if (!model.isSuccess) {
      final msg = model.message?.trim() ?? '';
      return FieldAgentAdsFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load ads.',
      );
    }

    return FieldAgentAdsFetchSuccess(model);
  }

  FieldAgentAdInterestResult _parseInterestBody(String body) {
    final parsed = _tryParseJsonObject(body);
    if (parsed == null) {
      return const FieldAgentAdInterestSuccess();
    }

    final apiError = _readErrorsText(parsed['errors']);
    if (apiError != null) {
      return FieldAgentAdInterestFailure(message: apiError);
    }

    final status = parsed['status'];
    final isSuccess = status == true ||
        status == 200 ||
        status == '200' ||
        status == 'true';

    final message = _readStringLike(parsed['message']);

    if (!isSuccess && status != null) {
      return FieldAgentAdInterestFailure(
        message: message ?? 'Could not submit interest.',
      );
    }

    return FieldAgentAdInterestSuccess(message: message);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _readStringLike(parsed?['message']) ??
        _readErrorsText(parsed?['errors']);

    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    switch (statusCode) {
      case 401:
      case 403:
        return 'Unauthorized. Please sign in again.';
      case 404:
        return 'Ads not found.';
      default:
        return 'Request failed ($statusCode).';
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
      final map = Map<String, dynamic>.from(rawErrors);
      for (final v in map.values) {
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
