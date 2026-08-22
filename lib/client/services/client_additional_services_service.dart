import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_additional_service_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientAdditionalServicesFetchResult {
  const ClientAdditionalServicesFetchResult();
}

final class ClientAdditionalServicesFetchSuccess
    extends ClientAdditionalServicesFetchResult {
  const ClientAdditionalServicesFetchSuccess(this.model);

  final ClientAdditionalServiceModel model;
}

final class ClientAdditionalServicesFetchFailure
    extends ClientAdditionalServicesFetchResult {
  const ClientAdditionalServicesFetchFailure({required this.message});

  final String message;
}

sealed class ClientAdditionalServiceSubmitResult {
  const ClientAdditionalServiceSubmitResult();
}

final class ClientAdditionalServiceSubmitSuccess
    extends ClientAdditionalServiceSubmitResult {
  const ClientAdditionalServiceSubmitSuccess({required this.message});

  final String message;
}

final class ClientAdditionalServiceSubmitFailure
    extends ClientAdditionalServiceSubmitResult {
  const ClientAdditionalServiceSubmitFailure({required this.message});

  final String message;
}

/// Additional services APIs for the Client module.
class ClientAdditionalServicesService {
  ClientAdditionalServicesService({http.Client? httpClient})
      : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientAdditionalServicesFetchResult> fetchAdditionalServices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientAdditionalServicesFetchFailure(message: '');
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientAdditionalServicesFetchFailure(message: '');
    }

    final uri = Uri.tryParse('$base/user/additional-services');
    if (uri == null || !uri.hasScheme) {
      return const ClientAdditionalServicesFetchFailure(message: '');
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
        return const ClientAdditionalServicesFetchFailure(
          message: SessionExpiryHandler.message,
        );
      }

      if (response.statusCode == 200) {
        return _parseSuccessBody(response.body);
      }

      return ClientAdditionalServicesFetchFailure(
        message: _readApiMessage(response.body),
      );
    } on http.ClientException {
      return const ClientAdditionalServicesFetchFailure(message: '');
    } on FormatException {
      return const ClientAdditionalServicesFetchFailure(message: '');
    } catch (_) {
      return const ClientAdditionalServicesFetchFailure(message: '');
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  ClientAdditionalServicesFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientAdditionalServicesFetchFailure(message: '');
    }

    final decoded = jsonDecode(trimmed);

    final ClientAdditionalServiceModel model;
    if (decoded is List) {
      model = ClientAdditionalServiceModel(
        status: true,
        message: '',
        data: ClientAdditionalServiceModel.parseServiceList(decoded),
        errors: null,
      );
    } else if (decoded is Map) {
      model = ClientAdditionalServiceModel.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } else {
      return const ClientAdditionalServicesFetchFailure(message: '');
    }

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientAdditionalServicesFetchFailure(message: apiError);
    }

    if (!model.status) {
      return ClientAdditionalServicesFetchFailure(
        message: _combinedApiMessage(model.message, model.errors),
      );
    }

    return ClientAdditionalServicesFetchSuccess(model);
  }

  /// POST `{live_url}/user/additional-services/store`.
  Future<ClientAdditionalServiceSubmitResult> submitAdditionalService({
    required String serviceType,
    String? comments,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientAdditionalServiceSubmitFailure(message: '');
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientAdditionalServiceSubmitFailure(message: '');
    }

    final uri = Uri.tryParse('$base/user/additional-services/store');
    if (uri == null || !uri.hasScheme) {
      return const ClientAdditionalServiceSubmitFailure(message: '');
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
          'service_type': serviceType,
          'comments': comments,
        }),
      );

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode,
        body: response.body,
      )) {
        return const ClientAdditionalServiceSubmitFailure(
          message: SessionExpiryHandler.message,
        );
      }

      final parsed = _tryParseJsonObject(response.body);
      if (parsed == null) {
        return const ClientAdditionalServiceSubmitFailure(message: '');
      }

      final errorsText = _readErrorsText(parsed['errors']);
      if (errorsText != null) {
        return ClientAdditionalServiceSubmitFailure(message: errorsText);
      }

      final messageText = _combinedApiMessage(
        parsed['message'],
        parsed['errors'],
      );

      if (_isSubmitSuccess(parsed, response.statusCode)) {
        return ClientAdditionalServiceSubmitSuccess(message: messageText);
      }

      return ClientAdditionalServiceSubmitFailure(message: messageText);
    } on http.ClientException {
      return const ClientAdditionalServiceSubmitFailure(message: '');
    } on FormatException {
      return const ClientAdditionalServiceSubmitFailure(message: '');
    } catch (_) {
      return const ClientAdditionalServiceSubmitFailure(message: '');
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  bool _isSubmitSuccess(Map<String, dynamic> json, int httpStatusCode) {
    final apiStatus = json['status'];
    if (apiStatus is bool && apiStatus) return true;
    if (apiStatus is int && apiStatus == 200) return true;
    if (apiStatus is num && apiStatus == 200) return true;
    if (apiStatus is String) {
      final text = apiStatus.trim().toLowerCase();
      if (text == '200' || text == 'true') return true;
    }

    return httpStatusCode >= 200 &&
        httpStatusCode < 300 &&
        json['errors'] == null;
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
