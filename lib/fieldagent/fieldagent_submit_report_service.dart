import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:proplilly/auth/auth_preferences.dart';
import 'package:proplilly/auth/session_expiry_handler.dart';
import 'package:proplilly/client/services/client_live_url_api.dart';
import 'package:proplilly/fieldagent/fieldagent_submit_report_model.dart';
import 'package:proplilly/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class FieldAgentSubmitReportResult {
  const FieldAgentSubmitReportResult();
}

final class FieldAgentSubmitReportSuccess extends FieldAgentSubmitReportResult {
  const FieldAgentSubmitReportSuccess(this.model);

  final FieldAgentSubmitReportModel model;
}

final class FieldAgentSubmitReportFailure extends FieldAgentSubmitReportResult {
  const FieldAgentSubmitReportFailure({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;
}

/// Submits a visit report to
/// `POST {live_url}/coordinator_api/tasks/{task_id}/report`.
class FieldAgentSubmitReportService {
  FieldAgentSubmitReportService({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  Future<FieldAgentSubmitReportResult> submitReport({
    required String taskId,
    required String reportComment,
    required List<File> propertyImages,
    File? propertyVideo,
  }) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      return const FieldAgentSubmitReportFailure(
        message: 'Task ID is missing.',
      );
    }

    if (propertyImages.isEmpty) {
      return const FieldAgentSubmitReportFailure(
        message: 'Please upload at least one property image.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final token =
        prefs.getString(AuthPreferenceKeys.token)?.trim() ?? '';

    if (token.isEmpty) {
      return const FieldAgentSubmitReportFailure(
        message: 'Please sign in again.',
        statusCode: 401,
      );
    }

    final base = await LiveUrlApi.getBaseUrl();
    if (base == null) {
      return const FieldAgentSubmitReportFailure(
        message: 'Server URL is not configured. Please try again later.',
      );
    }

    final uri = _buildReportUri(base, trimmedTaskId);
    if (uri == null) {
      return const FieldAgentSubmitReportFailure(
        message: 'Invalid server URL configuration.',
      );
    }

    final ownsDio = _dio == null;
    final dio = _dio ?? Dio();

    try {
      final imageParts = <MultipartFile>[];
      for (final image in propertyImages) {
        final fileName = image.path.split(Platform.pathSeparator).last;
        imageParts.add(
          await MultipartFile.fromFile(
            image.path,
            filename: fileName,
          ),
        );
      }

      final formMap = <String, dynamic>{
        'report_comment': reportComment.trim(),
        'property_images[]': imageParts,
      };

      if (propertyVideo != null) {
        final videoName = propertyVideo.path.split(Platform.pathSeparator).last;
        formMap['video'] = await MultipartFile.fromFile(
          propertyVideo.path,
          filename: videoName,
        );
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
        return const FieldAgentSubmitReportFailure(
          message: SessionExpiryHandler.message,
          statusCode: 401,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseSuccessBody(responseBody);
      }

      return FieldAgentSubmitReportFailure(
        message: _messageForStatus(
          response.statusCode ?? 0,
          responseBody,
        ),
        statusCode: response.statusCode,
      );
    } on DioException {
      return const FieldAgentSubmitReportFailure(
        message: 'Network error. Check your connection and try again.',
      );
    } catch (e) {
      return FieldAgentSubmitReportFailure(
        message: 'Something went wrong: $e',
      );
    } finally {
      if (ownsDio) {
        dio.close();
      }
    }
  }

  Uri? _buildReportUri(String base, String taskId) {
    final uri = Uri.tryParse('$base/coordinator_api/tasks/$taskId/report');
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  FieldAgentSubmitReportResult _parseSuccessBody(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const FieldAgentSubmitReportFailure(
        message: 'Report response is empty. Please try again.',
      );
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const FieldAgentSubmitReportFailure(
        message: 'Invalid report response.',
      );
    }

    final model = FieldAgentSubmitReportModel.fromJson(decoded);

    final apiError = _readErrorsText(model.errors);
    if (apiError != null) {
      return FieldAgentSubmitReportFailure(message: apiError);
    }

    if (!model.isSuccess) {
      final msg = model.message?.trim() ?? '';
      return FieldAgentSubmitReportFailure(
        message: msg.isNotEmpty ? msg : 'Failed to submit report.',
      );
    }

    return FieldAgentSubmitReportSuccess(model);
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
        return 'Report endpoint not found.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again in a few moments.';
      default:
        return 'Failed to submit report.';
    }
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
