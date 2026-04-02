import 'dart:convert';
import 'dart:io';
import '../models/visit_model.dart';
import '../models/user_dashboard_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../utils/preferences.dart';
import 'auth_service.dart';
import 'base_api_service.dart';
import 'admin_service.dart';

class VisitService extends BaseApiService {
  static final VisitService _instance = VisitService._internal();
  factory VisitService() => _instance;
  VisitService._internal();

  Future<List<Visit>> getVisitsByProperty(String propertyId) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}visits?propertyId=$propertyId');

      final data = jsonDecode(response.body);
      return (data['visits'] as List)
          .map((json) => Visit.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Visit>> getTodayVisits() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final coordinatorId = AuthService().currentUser?.id;
      if (coordinatorId == null) return [];

      final response = await get('${baseUrl}visits/today?coordinatorId=$coordinatorId');

      final data = jsonDecode(response.body);
      return (data['visits'] as List)
          .map((json) => Visit.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Visit?> startVisit({
    required String propertyId,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final coordinatorId = AuthService().currentUser?.id;
      if (coordinatorId == null) return null;

      final response = await post('${baseUrl}visits/start', {
        'propertyId': propertyId,
        'coordinatorId': coordinatorId,
        'latitude': latitude,
        'longitude': longitude,
        'notes': notes,
      });

      final data = jsonDecode(response.body);
      return Visit.fromJson(data['visit']);
    } catch (e) {
      return null;
    }
  }

  Future<Visit?> endVisit({
    required String visitId,
    required double latitude,
    required double longitude,
    required List<String> imageUrls,
    String? remarks,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}visits/$visitId/end', {
        'latitude': latitude,
        'longitude': longitude,
        'imageUrls': imageUrls,
        'remarks': remarks,
      });

      final data = jsonDecode(response.body);
      return Visit.fromJson(data['visit']);
    } catch (e) {
      return null;
    }
  }
}
