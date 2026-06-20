import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_ads_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientAdsFetchResult {
  const ClientAdsFetchResult();
}

final class ClientAdsFetchSuccess extends ClientAdsFetchResult {
  const ClientAdsFetchSuccess(this.model);

  final ClientAdsModel model;
}

final class ClientAdsFetchFailure extends ClientAdsFetchResult {
  const ClientAdsFetchFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

sealed class ClientAdInterestResult {
  const ClientAdInterestResult();
}

final class ClientAdInterestSuccess extends ClientAdInterestResult {
  const ClientAdInterestSuccess({this.message});

  final String? message;
}

final class ClientAdInterestFailure extends ClientAdInterestResult {
  const ClientAdInterestFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Ads API for Client module.
class ClientAdsService {
  ClientAdsService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientAdsFetchResult> fetchAds() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientAdsFetchFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientAdsFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/ads');
    if (uri == null || !uri.hasScheme) {
      return const ClientAdsFetchFailure(
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
        return const ClientAdsFetchFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200) {
        return _parseFetchSuccessBody(response.body);
      }

      return ClientAdsFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const ClientAdsFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientAdsFetchFailure(
        message: 'Could not read ads data. Please try again.',
      );
    } catch (e) {
      return ClientAdsFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Future<ClientAdInterestResult> submitInterest({
    required String adId,
    required String interestResponse,
    String? interestNotes,
  }) async {
    final trimmedAdId = adId.trim();
    if (trimmedAdId.isEmpty) {
      return const ClientAdInterestFailure(message: 'Ad ID is missing.');
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientAdInterestFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientAdInterestFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/ads/interest');
    if (uri == null || !uri.hasScheme) {
      return const ClientAdInterestFailure(
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
        return const ClientAdInterestFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseInterestBody(response.body);
      }

      return ClientAdInterestFailure(
        message: _messageForStatus(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    } on http.ClientException {
      return const ClientAdInterestFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientAdInterestFailure(
        message: 'Could not read interest response. Please try again.',
      );
    } catch (e) {
      return ClientAdInterestFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientAdsFetchResult _parseFetchSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientAdsFetchFailure(
        message: 'Ads data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const ClientAdsFetchFailure(
        message: 'Invalid ads response.',
      );
    }

    final model = ClientAdsModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientAdsFetchFailure(message: apiError);
    }

    if (!model.isSuccess) {
      final msg = model.message?.trim() ?? '';
      return ClientAdsFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load ads.',
      );
    }

    return ClientAdsFetchSuccess(model);
  }

  ClientAdInterestResult _parseInterestBody(String body) {
    final parsed = _tryParseJsonObject(body);
    if (parsed == null) {
      return const ClientAdInterestSuccess();
    }

    final apiError = _readErrorsText(parsed['errors']);
    if (apiError != null) {
      return ClientAdInterestFailure(message: apiError);
    }

    final status = parsed['status'];
    final isSuccess = status == true ||
        status == 200 ||
        status == '200' ||
        status == 'true';

    final message = _readStringLike(parsed['message']);

    if (!isSuccess && status != null) {
      return ClientAdInterestFailure(
        message: message ?? 'Could not submit interest.',
      );
    }

    return ClientAdInterestSuccess(message: message);
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
