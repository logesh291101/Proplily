import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';
import '../services/coordinator_service.dart';

class CoordinatorProvider with ChangeNotifier {
  final CoordinatorService _coordinatorService = CoordinatorService();
  
  List<Property> _assignedProperties = [];
  bool _isLoading = false;

  List<Property> get assignedProperties => _assignedProperties;
  bool get isLoading => _isLoading;

  Future<void> fetchAssignedProperties() async {
    _isLoading = true;
    notifyListeners();
    _assignedProperties = await _coordinatorService.getAssignedProperties();
    _isLoading = false;
    notifyListeners();
  }

  Future<User?> getClientDetails(String propertyId) async {
    return await _coordinatorService.getClientDetails(propertyId);
  }

  Future<bool> submitReport({
    required String propertyId,
    required String reportSummary,
    required String status,
  }) async {
    final success = await _coordinatorService.submitReport(
      propertyId: propertyId,
      reportSummary: reportSummary,
      status: status,
    );
    if (success) {
      await fetchAssignedProperties();
    }
    return success;
  }
}
