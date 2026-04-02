import 'dart:convert';
import 'dart:io';
import '../models/maintenance_model.dart';
import '../utils/preferences.dart';
import 'base_api_service.dart';

class MaintenanceService extends BaseApiService {
  Future<List<MaintenanceRequest>> getMaintenanceList() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/maintenance');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((m) => MaintenanceRequest.fromJson(m)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createMaintenanceRequest({
    required String propertyId,
    required String description,
    required List<File> photos,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await multipartPost(
        url: '${baseUrl}user/maintenance/store',
        fields: {
          'property_id': propertyId,
          'description': description,
        },
        files: photos,
        fieldName: 'photos[]',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
