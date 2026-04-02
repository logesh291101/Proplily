import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../models/inspection_model.dart';
import '../services/property_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  
  List<Property> _properties = [];
  bool _isLoading = false;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchProperties() async {
    _setLoading(true);
    _properties = await _propertyService.getProperties();
    _setLoading(false);
  }

  Future<bool> addProperty({
    required String propertyName,
    required PropertyType propertyType,
    required String propertyAddress,
    required String city,
    required double latitude,
    required double longitude,
    File? propertyPhoto,
  }) async {
    _setLoading(true);
    final success = await _propertyService.addProperty(
      propertyName: propertyName,
      propertyType: propertyType,
      propertyAddress: propertyAddress,
      city: city,
      latitude: latitude,
      longitude: longitude,
      propertyPhoto: propertyPhoto,
    );
    _isLoading = false;
    if (success) {
      await fetchProperties();
    }
    notifyListeners();
    return success;
  }

  Future<bool> deleteProperty(String id) async {
    final success = await _propertyService.deleteProperty(id);
    if (success) {
      _properties.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return success;
  }

  Future<List<Inspection>> getInspections(String id) async {
    return await _propertyService.getInspections(id);
  }

  Future<bool> requestVisit(String id) async {
    return await _propertyService.requestVisit(id);
  }

  // Compatibility members
  Future<List<Property>> getApprovedProperties() async {
    return await _propertyService.getApprovedProperties();
  }

  Future<List<Property>> getPendingProperties() async {
    return await _propertyService.getPendingProperties();
  }

  Future<Property?> getPropertyById(String id) async {
    return await _propertyService.getPropertyById(id);
  }

  Future<List<Property>> getAssignedProperties([String? coordinatorId]) async {
    return await _propertyService.getAssignedProperties(coordinatorId);
  }

  Future<bool> approveProperty(String id) async {
    final success = await _propertyService.approveProperty(id);
    if (success) await fetchProperties();
    return success;
  }

  Future<bool> rejectProperty(String propertyId) async {
    _setLoading(true);
    final success = await _propertyService.rejectProperty(propertyId);
    _setLoading(false);
    if (success) {
      await fetchProperties();
    }
    return success;
  }

  Future<bool> assignCoordinator(String propertyId, String coordinatorId) async {
    final success = await _propertyService.assignCoordinator(propertyId, coordinatorId);
    if (success) await fetchProperties();
    return success;
  }
}
