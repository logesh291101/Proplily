import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:http/http.dart' as http;

import '../models/property_model.dart';
import '../models/inspection_model.dart';
import '../utils/preferences.dart';
import '../utils/constants.dart';
import 'base_api_service.dart';
import 'admin_service.dart';
import 'coordinator_service.dart';

class PropertyService extends BaseApiService {
  Future<List<Property>> getProperties() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/properties');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List).map((p) => Property.fromJson(p)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Future<bool> storeProperty({
  //   required String propertyName,
  //   String? address,
  //   String? propertyAddress,
  //   String? city,
  //   required dynamic propertyType,
  //   required double latitude,
  //   required double longitude,
  //   File? propertyPhoto,
  // }) async {
  //   try {
  //     final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
  //     final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
  //
  //     final token = Prefs.getString(AppConstants.tokenKey) ?? 'No Token Found';
  //     log("token--------$token");
  //
  //     final typeStr = propertyType is PropertyType
  //       ? propertyType.toString().split('.').last
  //       : propertyType.toString();
  //
  //
  //     final response = await multipartPost(
  //       url: '${baseUrl}user/properties/store',
  //       // headers: {
  //       //   "Authorization": "Bearer $token",
  //       // },
  //       fields: {
  //         'property_name': propertyName,
  //         'address': propertyAddress ?? address ?? '',
  //         'city': city ?? '',
  //         'property_type': typeStr,
  //         'latitude': latitude.toString(),
  //         'longitude': longitude.toString(),
  //       },
  //       files: propertyPhoto != null ? [propertyPhoto] : [],
  //       fieldName: 'property_photo',
  //     );
  //
  //     log("-------response$response");
  //     return response.statusCode == 200 || response.statusCode == 201;
  //
  //   } catch (e) {
  //     return false;
  //   }
  // }

  Future<bool> storeProperty({
    required String propertyName,
    String? address,
    String? propertyAddress,
    String? city,
    required dynamic propertyType,
    required double latitude,
    required double longitude,
    File? propertyPhoto,
  }) async {
    try {
      final liveUrl =
          Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl =
      liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';

      final token = Prefs.getString(AppConstants.tokenKey) ?? '';

      if (token.isEmpty) {
        log("❌ Token missing");
        return false;
      }

      log("🔑 TOKEN: $token");

      // ✅ Convert property type
      final typeStr = propertyType is PropertyType
          ? propertyType.toString().split('.').last
          : propertyType.toString();

      // ✅ Convert image to Base64 (if exists)
      String? base64Image;
      if (propertyPhoto != null) {
        final bytes = await propertyPhoto.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // ✅ Prepare JSON body
      final body = {
        'property_name': propertyName,
        'address': propertyAddress ?? address ?? '',
        'city': city ?? '',
        'property_type': typeStr,
        'latitude': latitude,
        'longitude': longitude,
        if (base64Image != null) 'property_photo': base64Image,
      };

      log("📦 BODY: ${jsonEncode(body)}");

      // ✅ API Call
      final response = await http.post(
        Uri.parse('${baseUrl}user/properties/store'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      log("📡 STATUS CODE: ${response.statusCode}");
      log("📡 RESPONSE: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;

    } catch (e) {
      log("❌ ERROR: $e");
      return false;
    }
  }

  Future<bool> addProperty({
    required String propertyName,
    String? address,
    String? propertyAddress,
    String? city,
    required dynamic propertyType,
    required double latitude,
    required double longitude,
    File? propertyPhoto,
  }) async {
    return storeProperty(
      propertyName: propertyName,
      address: address,
      propertyAddress: propertyAddress,
      city: city,
      propertyType: propertyType,
      latitude: latitude,
      longitude: longitude,
      propertyPhoto: propertyPhoto,
    );
  }

  Future<bool> updateProperty({
    required String id,
    required String propertyName,
    required String address,
    required String city,
    required String propertyType,
    required double latitude,
    required double longitude,
    File? propertyPhoto,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      if (propertyPhoto != null) {
        final response = await multipartPost(
          url: '${baseUrl}user/properties/update/$id',
          fields: {
            'property_name': propertyName,
            'address': address,
            'city': city,
            'property_type': propertyType,
            'latitude': latitude.toString(),
            'longitude': longitude.toString(),
          },
          files: [propertyPhoto],
          fieldName: 'property_photo',
        );
        return response.statusCode == 200;
      } else {
        final response = await post('${baseUrl}user/properties/update/$id', {
          'property_name': propertyName,
          'address': address,
          'city': city,
          'property_type': propertyType,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        });
        return response.statusCode == 200;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProperty(String id) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}user/properties/delete/$id', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Inspection>> getInspections(String id) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/properties/$id/inspections');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((i) => Inspection.fromJson(i)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> requestVisit(String id) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}user/properties/$id/request-visit', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Compatibility methods
  Future<List<Property>> getApprovedProperties() async {
    final properties = await getProperties();
    return properties.where((p) => p.status == PropertyStatus.approved).toList();
  }

  Future<List<Property>> getPendingProperties() async {
    final properties = await getProperties();
    return properties.where((p) => p.status == PropertyStatus.pendingVerification || p.status == PropertyStatus.propertyAdded).toList();
  }

  Future<Property?> getPropertyById(String id) async {
    final properties = await getProperties();
    try {
      return properties.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Property>> getAssignedProperties([String? coordinatorId]) async {
    return await CoordinatorService().getAssignedProperties();
  }

  Future<bool> approveProperty(String id) async {
    return await AdminService().verifyProperty(id, 'approved');
  }

  Future<bool> rejectProperty(String id) async {
    return await AdminService().verifyProperty(id, 'rejected');
  }

  Future<bool> assignCoordinator(String propertyId, String coordinatorId) async {
    return await AdminService().assignCoordinator(propertyId, coordinatorId);
  }
}
