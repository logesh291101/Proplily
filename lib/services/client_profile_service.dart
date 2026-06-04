import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/models/client_profile_model.dart';
import 'package:proplilly/services/auth_preferences.dart';
import 'package:proplilly/services/live_url_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ClientProfileFetchResult {
  const ClientProfileFetchResult();
}

final class ClientProfileFetchSuccess extends ClientProfileFetchResult {
  const ClientProfileFetchSuccess(this.model);

  final ClientProfileModel model;
}

final class ClientProfileFetchFailure extends ClientProfileFetchResult {
  const ClientProfileFetchFailure({required this.message});

  final String message;
}

/// Fetches client profile from `GET {live_url}/user/profile`.
class ClientProfileService {
  ClientProfileService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  Future<ClientProfileFetchResult> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const ClientProfileFetchFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const ClientProfileFetchFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildProfileUri(base);
    if (uri == null) {
      return const ClientProfileFetchFailure(
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
        return _parseSuccessBody(response.body);
      }

      return ClientProfileFetchFailure(
        message: _messageForStatus(response.statusCode, response.body),
      );
    } on http.ClientException {
      return const ClientProfileFetchFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } on FormatException {
      return const ClientProfileFetchFailure(
        message: 'Could not read profile data. Please try again.',
      );
    } catch (e) {
      return ClientProfileFetchFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildProfileUri(String base) {
    final uri = Uri.tryParse('$base/user/profile');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  ClientProfileFetchResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const ClientProfileFetchFailure(
        message: 'Profile data is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const ClientProfileFetchFailure(
        message: 'Invalid profile response.',
      );
    }

    final model = ClientProfileModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return ClientProfileFetchFailure(message: apiError);
    }

    if (!model.status || model.data == null) {
      final msg = model.message.trim();
      return ClientProfileFetchFailure(
        message: msg.isNotEmpty ? msg : 'Could not load profile.',
      );
    }

    return ClientProfileFetchSuccess(model);
  }

  String _messageForStatus(int statusCode, String body) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _messageFromBody(parsed) ??
        _readErrorsFromParsed(parsed);

    switch (statusCode) {
      case 401:
      case 403:
        return apiMessage ?? 'Unauthorized. Please sign in again.';
      case 404:
        return apiMessage ?? 'Profile not found.';
      default:
        if (statusCode >= 500) {
          return apiMessage ??
              'Server error. Please try again in a few moments.';
        }
        return apiMessage ?? 'Could not load profile ($statusCode).';
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

  String? _readErrorsFromParsed(Map<String, dynamic>? json) {
    if (json == null) return null;
    return _readErrorsText(json['errors']);
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

  String? _messageFromBody(Map<String, dynamic>? json) {
    if (json == null) return null;
    return _readStringLike(json['message']);
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
