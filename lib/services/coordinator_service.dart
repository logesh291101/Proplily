import 'dart:convert';
import '../models/property_model.dart';
import '../models/user_model.dart';
import '../utils/preferences.dart';
import 'base_api_service.dart';

class CoordinatorService extends BaseApiService {
  Future<List<Property>> getAssignedProperties([String? coordinatorId]) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final endpointSpace = coordinatorId != null ? 'coordinator_api/properties?id=$coordinatorId' : 'coordinator_api/properties';
      final response = await get('$baseUrl$endpointSpace');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((p) => Property.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<User?> getClientDetails(String propertyId) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}coordinator_api/property/$propertyId/client');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitReport({
    required String propertyId,
    required String reportSummary,
    required String status,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}coordinator_api/report', {
        'property_id': propertyId,
        'report_summary': reportSummary,
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
