import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../utils/preferences.dart';
import '../utils/constants.dart';

class BaseApiService {

  Map<String, String> _getHeaders() {
    final token = Prefs.getString(AppConstants.tokenKey);
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      log("🔑 Added JWT Token to request headers: ${token.length > 10 ? token.substring(0, 10) : token}...");
    } else {
      log("⚠️ No JWT Token found in Preferences for request");
    }

    return headers;
  }

  Future<http.Response> get(String url) async {
    final headers = _getHeaders();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  Future<http.Response> post(String url, dynamic body) async {
    final headers = _getHeaders();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  Future<http.Response> put(String url, dynamic body) async {
    final headers = _getHeaders();
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  Future<http.Response> delete(String url) async {
    final headers = _getHeaders();
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Handle Multi-part request for image/file uploads
  Future<http.StreamedResponse> multipartPost({
    required String url,
    required Map<String, String> fields,
    required List<File> files,
    required String fieldName,
  }) async {
    final headers = _getHeaders();
    headers.remove('Content-Type'); // http handles this for multipart

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..fields.addAll(fields);

    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    }

    try {
      return await request.send();
    } catch (e) {
      throw Exception('Multipart POST request failed: $e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Return more detailed error message from server if available
      String errorMessage;
      try {
        final body = jsonDecode(response.body);
        if (body['messages'] != null && body['messages'] is Map) {
          final msgs = body['messages'] as Map;
          errorMessage = msgs.values.join(', ');
        } else {
          errorMessage = body['message'] ?? body['error'] ?? 'API error: ${response.statusCode}';
        }
      } catch (_) {
        errorMessage = 'API error: ${response.statusCode} - ${response.body}';
      }
      throw Exception(errorMessage);
    }
  }
}
