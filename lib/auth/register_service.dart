import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proplilly/remote_config/remote_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of calling [RegisterService.register].
sealed class RegisterResult {
  const RegisterResult();
}

/// API returned `"status": 200` in the JSON body.
final class RegisterSuccess extends RegisterResult {
  const RegisterSuccess({required this.message});

  final String message;
}

/// Network error, parse error, or JSON `"status"` not equal to 200.
final class RegisterFailure extends RegisterResult {
  const RegisterFailure({
    required this.message,
    this.apiStatus,
    this.httpStatusCode,
  });

  final String message;
  final int? apiStatus;
  final int? httpStatusCode;
}

/// POST sign-up using base URL from SharedPreferences (`live_url`).
///
/// Endpoint: `{live_url}/api/register` with body `{ "email": "<email>" }`.
///
/// The API is expected to respond with JSON such as:
/// `{ "status": 200, "message": "Registration email sent successfully." }`.
/// Success is determined by the **`status` field in the body**, not only HTTP code.
class RegisterService {
  RegisterService({http.Client? httpClient}) : _httpClient = httpClient;

  final http.Client? _httpClient;

  /// Reads `live_url` via [SharedPreferences.getString].
  Future<RegisterResult> register({required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    final liveUrl =
        prefs.getString(RemoteConfigKeys.liveUrl)?.trim() ?? '';

    if (liveUrl.isEmpty) {
      return const RegisterFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildRegisterUri(liveUrl);
    if (uri == null) {
      return const RegisterFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    final ownsClient = _httpClient == null;
    final client = _httpClient ?? http.Client();

    try {
      final response = await client.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      final parsed = _tryParseJsonObject(response.body);

      if (parsed == null) {
        return RegisterFailure(
          message: response.body.trim().isEmpty
              ? 'Invalid or empty response from server.'
              : 'Could not read server response.',
          httpStatusCode: response.statusCode,
        );
      }

      final apiStatus = _readApiStatus(parsed);
      final apiMessage = _readMessage(parsed);

      if (apiStatus == 200) {
        return RegisterSuccess(
          message: apiMessage ?? 'Registration email sent successfully.',
        );
      }

      return RegisterFailure(
        message: apiMessage ?? 'Registration failed.',
        apiStatus: apiStatus,
        httpStatusCode: response.statusCode,
      );
    } on http.ClientException catch (e) {
      return RegisterFailure(message: 'Connection error: ${e.message}');
    } on FormatException catch (e) {
      return RegisterFailure(message: 'Invalid response: ${e.message}');
    } catch (e) {
      return RegisterFailure(message: 'Something went wrong: $e');
    } finally {
      if (ownsClient) {
        client.close();
      }
    }
  }

  Uri? _buildRegisterUri(String liveUrl) {
    final trimmed = liveUrl.trim();
    if (trimmed.isEmpty) return null;

    var base = trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;

    final uri = Uri.tryParse('$base/api/register');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
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

  int? _readApiStatus(Map<String, dynamic> json) {
    final v = json['status'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  String? _readMessage(Map<String, dynamic> json) {
    final v = json['message'];
    if (v is String) {
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return null;
  }
}
