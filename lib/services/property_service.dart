import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class PropertyService {
  static final PropertyService _instance = PropertyService._internal();
  factory PropertyService() => _instance;
  PropertyService._internal();

  Future<List<Property>> getProperties() async {
    try {
      final token = AuthService().token;
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['properties'] as List)
            .map((json) => Property.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Property?> addProperty({
    required String propertyName,
    required PropertyType propertyType,
    required String propertyAddress,
    required String ownerName,
    required String contactNumber,
    required double latitude,
    required double longitude,
    required List<String> documentUrls,
    required List<String> propertyImages,
  }) async {
    // Simulate network delay for better UX demonstration
    await Future.delayed(const Duration(seconds: 2));

    final currentUser = AuthService().currentUser;
    final userId = currentUser?.id;
    if (userId == null) return null;

    // Handle Master User Mock Response
    if (currentUser?.email == AppConstants.masterEmail) {
      final mockId = 'mock-prop-${DateTime.now().millisecondsSinceEpoch}';
      return Property(
        id: mockId,
        propertyName: propertyName,
        propertyType: propertyType,
        propertyAddress: propertyAddress,
        ownerName: ownerName,
        contactNumber: contactNumber,
        latitude: latitude,
        longitude: longitude,
        documentUrls: documentUrls,
        propertyImages: propertyImages,
        ownerId: userId,
        status: PropertyStatus.pendingVerification,
        createdAt: DateTime.now(),
      );
    }

    try {
      final token = AuthService().token;
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'propertyName': propertyName,
          'propertyType': propertyType.toString().split('.').last,
          'propertyAddress': propertyAddress,
          'ownerName': ownerName,
          'contactNumber': contactNumber,
          'latitude': latitude,
          'longitude': longitude,
          'documentUrls': documentUrls,
          'propertyImages': propertyImages,
          'ownerId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Property.fromJson(data['property']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Property?> getPropertyById(String propertyId) async {
    try {
      final token = AuthService().token;
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/properties/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Property.fromJson(data['property']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
