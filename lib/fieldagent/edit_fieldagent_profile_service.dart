import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class EditFieldAgentProfileResult {
  const EditFieldAgentProfileResult();
}

final class EditFieldAgentProfileSuccess extends EditFieldAgentProfileResult {
  const EditFieldAgentProfileSuccess({this.message});

  final String? message;
}

final class EditFieldAgentProfileFailure extends EditFieldAgentProfileResult {
  const EditFieldAgentProfileFailure({this.message});

  final String? message;
}

/// POST `{live_url}/user/profile/update` with only the changed profile fields.
class EditFieldAgentProfileService {
  EditFieldAgentProfileService({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  Future<EditFieldAgentProfileResult> updateProfile({
    String? name,
    String? phone,
    String? profileImagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    final uri = _buildUpdateUri(base);
    if (uri == null) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    final formMap = <String, dynamic>{};

    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      formMap['name'] = trimmedName;
    }

    final trimmedPhone = phone?.trim();
    if (trimmedPhone != null && trimmedPhone.isNotEmpty) {
      formMap['phone'] = trimmedPhone;
    }

    final trimmedImagePath = profileImagePath?.trim();
    if (trimmedImagePath != null &&
        trimmedImagePath.isNotEmpty &&
        File(trimmedImagePath).existsSync()) {
      final fileName = trimmedImagePath.split(Platform.pathSeparator).last;
      formMap['profile_image'] = await MultipartFile.fromFile(
        trimmedImagePath,
        filename: fileName,
      );
    }

    if (formMap.isEmpty) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    final ownsDio = _dio == null;
    final dio = _dio ?? Dio();

    try {
      final formData = FormData.fromMap(formMap);

      final response = await dio.post<dynamic>(
        uri.toString(),
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          contentType: 'multipart/form-data',
          validateStatus: (_) => true,
        ),
      );

      return _parseUpdateResponse(
        prefs: prefs,
        updatedName: trimmedName,
        statusCode: response.statusCode ?? 0,
        body: _encodeResponseBody(response.data),
      );
    } on DioException {
      return const EditFieldAgentProfileFailure(message: null);
    } catch (_) {
      return const EditFieldAgentProfileFailure(message: null);
    } finally {
      if (ownsDio) {
        dio.close();
      }
    }
  }

  Future<EditFieldAgentProfileResult> _parseUpdateResponse({
    required SharedPreferences prefs,
    required int statusCode,
    required String body,
    String? updatedName,
  }) async {
    if (await ApiService.handleSessionExpiryIfNeeded(
      statusCode: statusCode,
      body: body,
    )) {
      return const EditFieldAgentProfileFailure(
        message: SessionExpiryHandler.message,
      );
    }

    final parsed = _tryParseJson(body);
    if (parsed == null) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    final errorsText = _readErrorsText(parsed['errors']);
    if (errorsText != null) {
      return EditFieldAgentProfileFailure(message: errorsText);
    }

    final messageText = _readMessageText(parsed);
    if (_isUpdateSuccess(parsed, statusCode)) {
      if (updatedName != null) {
        await _persistNameIfPresent(prefs, updatedName);
      }
      return EditFieldAgentProfileSuccess(message: messageText);
    }

    return EditFieldAgentProfileFailure(message: messageText);
  }

  String _encodeResponseBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map || data is List) {
      return jsonEncode(data);
    }
    return data.toString();
  }

  Future<void> _persistNameIfPresent(
    SharedPreferences prefs,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await prefs.setString(AuthPreferenceKeys.name, trimmed);
  }

  bool _isUpdateSuccess(Map<String, dynamic> json, int httpStatusCode) {
    final apiStatus = json['status'];
    if (apiStatus is int && apiStatus == 200) return true;
    if (apiStatus is num && apiStatus == 200) return true;
    if (apiStatus is bool && apiStatus) return true;
    if (apiStatus is String) {
      final t = apiStatus.trim();
      if (t == '200' || t.toLowerCase() == 'true') return true;
    }

    if (httpStatusCode == 200 && json['errors'] == null) {
      return true;
    }

    return false;
  }

  Uri? _buildUpdateUri(String base) {
    final uri = Uri.tryParse('$base/user/profile/update');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    final t = body.trim();
    if (t.isEmpty) return null;
    try {
      final d = jsonDecode(t);
      if (d is Map) {
        return Map<String, dynamic>.from(d);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _readErrorsText(dynamic rawErrors) {
    if (rawErrors == null) return null;

    if (rawErrors is Map) {
      final parts = <String>[];
      for (final v in Map<String, dynamic>.from(rawErrors).values) {
        final text = _readStringLike(v);
        if (text != null) parts.add(text);
      }
      if (parts.isEmpty) return null;
      return parts.join('\n');
    }

    return _readStringLike(rawErrors);
  }

  String? _readMessageText(Map<String, dynamic> parsed) {
    return _readStringLike(parsed['message']);
  }

  String? _readStringLike(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }
    if (raw is List && raw.isNotEmpty) {
      final parts = <String>[];
      for (final item in raw) {
        final text = _readStringLike(item);
        if (text != null) parts.add(text);
      }
      if (parts.isEmpty) return null;
      return parts.join('\n');
    }
    return null;
  }
}
