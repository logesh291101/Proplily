import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/client/models/client_billing_details.dart';
import 'package:proplilly/client/models/client_billing_model.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class BillingFetchResult {
  const BillingFetchResult();
}

final class BillingFetchSuccess extends BillingFetchResult {
  const BillingFetchSuccess(this.model);

  final ClientBillingModel model;
}

final class BillingFetchFailure extends BillingFetchResult {
  const BillingFetchFailure({required this.message});

  final String message;
}

/// Fetches billing from `GET {live_url}/user/billing`.
class BillingService {
  BillingService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  /// Legacy entry point used by older billing screens; loads from the API.
  Future<BillingDetails> loadBillingDetails() async {
    final result = await fetchBilling();

    switch (result) {
      case BillingFetchSuccess(:final model):
        if (model.data.isEmpty) {
          final msg = model.message.trim();
          throw Exception(
            msg.isNotEmpty ? msg : 'No billing information available.',
          );
        }
        final record = model.data.first;
        return BillingDetails(
          planName: record.planName,
          planPrice: record.planPrice,
          memberSince: record.startDate,
          renewalDate: record.endDate,
          transactionId: record.transactionId,
          paymentMethod: '',
          paymentStatus: PaymentStatus.fromString(record.paymentStatus),
          durationStart: record.startDate,
          durationEnd: record.endDate,
          transactionDate: record.createdAt,
          activities: const [],
        );
      case BillingFetchFailure(:final message):
        throw Exception(message);
    }
  }

  Future<BillingFetchResult> fetchBilling() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const BillingFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const BillingFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildBillingUri(base);
    if (uri == null) {
      return const BillingFetchFailure(
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
        return const BillingFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return BillingFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const BillingFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const BillingFetchFailure(
        message: 'Could not read billing data. Please try again.',
      );
    } catch (e) {
      return BillingFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildBillingUri(String base) {
    final uri = Uri.tryParse('$base/user/billing');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  BillingFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const BillingFetchFailure(
        message: 'Billing data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);

    final ClientBillingModel model;
    if (decoded is List) {
      model = ClientBillingModel(
        status: true,
        message: '',
        data: ClientBillingModel.parseBillingList(decoded),
        errors: null,
      );
    } else if (decoded is Map<String, dynamic>) {
      model = ClientBillingModel.fromJson(decoded);
    } else {
      return const BillingFetchFailure(
        message: 'Invalid billing response.',
      );
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return BillingFetchFailure(message: apiError);
    }

    if (!model.status) {
      final msg = model.message.trim();
      return BillingFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load billing.',
      );
    }

    return BillingFetchSuccess(model);
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
        return apiMessage ?? 'Billing not found.';
      default:
        if (statusCode >= 500) {
          return apiMessage ??
              'Server error. Please try again in a few moments.';
        }
        return apiMessage ?? 'Could not load billing ($statusCode).';
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
