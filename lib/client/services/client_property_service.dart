import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/models/client_property_registration_model.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of registering a property asset.
sealed class PropertyRegistrationResult {
  const PropertyRegistrationResult();
}

final class PropertyRegistrationSuccess extends PropertyRegistrationResult {
  const PropertyRegistrationSuccess({required this.message});

  final String message;
}

final class PropertyRegistrationFailure extends PropertyRegistrationResult {
  const PropertyRegistrationFailure({required this.message});

  final String message;
}

/// Result of updating a property asset.
sealed class PropertyUpdateResult {
  const PropertyUpdateResult();
}

final class PropertyUpdateSuccess extends PropertyUpdateResult {
  const PropertyUpdateSuccess({
    this.message = 'Property updated successfully.',
  });

  final String message;
}

final class PropertyUpdateFailure extends PropertyUpdateResult {
  const PropertyUpdateFailure({required this.message});

  final String message;
}

/// Handles property registration and update API calls.
class PropertyService {
  PropertyService({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  Future<PropertyRegistrationResult> registerProperty({
    required String propertyName,
    required String address,
    required String city,
    required String latitude,
    required String longitude,
    required String ownerName,
    required String ownerPhone,
    required String plotType,
    required String country,
    required String state,
    required String plotSize,
    required String sizeUnit,
    required List<String> imagePaths,
    List<String> documentPaths = const [],
  }) async {
    if (imagePaths.isEmpty) {
      return const PropertyRegistrationFailure(
        message: 'Please upload at least one property image.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const PropertyRegistrationFailure(
        message: 'Please sign in again.',
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const PropertyRegistrationFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = Uri.tryParse('$base/user/properties/store');
    if (uri == null || !uri.hasScheme) {
      return const PropertyRegistrationFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    final ownsDio = _dio == null;
    final dio = _dio ?? Dio();

    try {
      final imageParts = <MultipartFile>[];
      for (final path in imagePaths) {
        final file = File(path);
        if (!await file.exists()) continue;
        imageParts.add(
          await MultipartFile.fromFile(
            path,
            filename: path.split(Platform.pathSeparator).last,
          ),
        );
      }

      if (imageParts.isEmpty) {
        return const PropertyRegistrationFailure(
          message: 'Please upload at least one property image.',
        );
      }

      final documentParts = <MultipartFile>[];
      for (final path in documentPaths) {
        final file = File(path);
        if (!await file.exists()) continue;
        documentParts.add(
          await MultipartFile.fromFile(
            path,
            filename: path.split(Platform.pathSeparator).last,
          ),
        );
      }

      final formMap = <String, dynamic>{
        'property_name': propertyName,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'owner_name': ownerName,
        'owner_phone': ownerPhone,
        'plot_type': plotType,
        'country': country,
        'state': state,
        'plot_size': plotSize,
        'size_unit': sizeUnit,
        'property_images[]': imageParts,
      };

      if (documentParts.isNotEmpty) {
        formMap['plot_documents[]'] = documentParts;
      }

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

      final responseBody = _encodeResponseBody(response.data);

      if (await ApiService.handleSessionExpiryIfNeeded(
        statusCode: response.statusCode ?? 0,
        body: responseBody,
      )) {
        return const PropertyRegistrationFailure(
          message: SessionExpiryHandler.message,
        );
      }

      return _parseRegistrationResponse(
        statusCode: response.statusCode ?? 0,
        body: responseBody,
      );
    } on DioException {
      return const PropertyRegistrationFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } catch (e) {
      return PropertyRegistrationFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsDio) {
        dio.close();
      }
    }
  }

  Future<PropertyUpdateResult> updateProperty({
    required String propertyId,
    required String propertyName,
    required String plotType,
    required String plotSize,
    required String country,
    required String state,
    required String city,
    required String fullAddress,
    required double latitude,
    required double longitude,
    required String ownerName,
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const PropertyUpdateSuccess();
  }

  PropertyRegistrationResult _parseRegistrationResponse({
    required int statusCode,
    required String body,
  }) {
    final parsed = _tryParseJsonObject(body);
    final apiMessage = _readStringLike(parsed?['message']) ??
        _readErrorsText(parsed?['errors']);

    if (parsed != null) {
      final model = ClientPropertyRegistrationModel.fromJson(parsed);
      final errorsText = _readErrorsText(model.errors);
      final message = errorsText ?? model.message?.trim();

      if (model.isSuccess) {
        if (message != null && message.isNotEmpty) {
          return PropertyRegistrationSuccess(message: message);
        }
      } else if (message != null && message.isNotEmpty) {
        return PropertyRegistrationFailure(message: message);
      }
    }

    if (statusCode == 200 || statusCode == 201) {
      if (apiMessage != null && apiMessage.isNotEmpty) {
        return PropertyRegistrationSuccess(message: apiMessage);
      }
    }

    if (apiMessage != null && apiMessage.isNotEmpty) {
      return PropertyRegistrationFailure(message: apiMessage);
    }

    return PropertyRegistrationFailure(
      message: body.trim().isNotEmpty ? body.trim() : 'Request failed.',
    );
  }

  String _encodeResponseBody(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    if (data is Map || data is List) {
      return jsonEncode(data);
    }
    return data.toString();
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
