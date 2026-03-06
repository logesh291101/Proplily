import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visit_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class VisitService {
  static final VisitService _instance = VisitService._internal();
  factory VisitService() => _instance;
  VisitService._internal();

  Future<List<Visit>> getVisitsByProperty(String propertyId) async {
    try {
      final token = AuthService().token;
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visits?propertyId=$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['visits'] as List)
            .map((json) => Visit.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Visit>> getTodayVisits() async {
    try {
      final token = AuthService().token;
      final coordinatorId = AuthService().currentUser?.id;
      
      if (coordinatorId == null) return [];

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/visits/today?coordinatorId=$coordinatorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['visits'] as List)
            .map((json) => Visit.fromJson(json))
            .toList();
      }
      return [];
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
      final token = AuthService().token;
      final coordinatorId = AuthService().currentUser?.id;
      
      if (coordinatorId == null) return null;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/visits/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'propertyId': propertyId,
          'coordinatorId': coordinatorId,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Visit.fromJson(data['visit']);
      }
      return null;
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
      final token = AuthService().token;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/visits/$visitId/end'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'imageUrls': imageUrls,
          'remarks': remarks,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Visit.fromJson(data['visit']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
