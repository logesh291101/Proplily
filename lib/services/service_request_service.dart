import '../models/service_request_model.dart';
import '../models/property_model.dart';
import 'auth_service.dart';

class ServiceRequestService {
  static final ServiceRequestService _instance = ServiceRequestService._internal();
  factory ServiceRequestService() => _instance;
  ServiceRequestService._internal();

  final List<ServiceRequest> _mockRequests = [];

  Future<ServiceRequest?> createEmergencyRequest(Property property) async {
    await Future.delayed(const Duration(seconds: 1));
    final currentUser = AuthService().currentUser;
    if (currentUser == null) return null;

    final request = ServiceRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      requestType: ServiceRequestType.emergency,
      propertyName: property.propertyName,
      propertyType: property.propertyType,
      propertyAddress: property.propertyAddress,
      city: property.city,
      ownerName: currentUser.fullName,
      contactNumber: currentUser.phoneNumber,
      latitude: property.latitude,
      longitude: property.longitude,
      propertyPhoto: property.propertyPhoto,
      description: 'Emergency inspection requested by owner',
      isEmergency: true,
      status: ServiceRequestStatus.pendingVerification,
      ownerId: currentUser.id,
      createdAt: DateTime.now(),
    );


    _mockRequests.add(request);
    return request;
  }

  Future<List<ServiceRequest>> getPendingEmergencyRequests() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockRequests.where((r) => r.isEmergency && r.status == ServiceRequestStatus.pendingVerification).toList();
  }

  Future<List<ServiceRequest>> getAssignedRequests(String coordinatorId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockRequests.where((r) => r.assignedToId == coordinatorId).toList();
  }

  Future<bool> updateRequestStatus(String requestId, ServiceRequestStatus status, {String? coordinatorId}) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _mockRequests.indexWhere((r) => r.id == requestId);
    if (index >= 0) {
      final old = _mockRequests[index];
      _mockRequests[index] = ServiceRequest(
        id: old.id,
        requestType: old.requestType,
        propertyName: old.propertyName,
        propertyType: old.propertyType,
        propertyAddress: old.propertyAddress,
        city: old.city,
        ownerName: old.ownerName,
        contactNumber: old.contactNumber,
        latitude: old.latitude,
        longitude: old.longitude,
        propertyPhoto: old.propertyPhoto,
        description: old.description,
        isEmergency: old.isEmergency,
        status: status,
        assignedToId: coordinatorId ?? old.assignedToId,
        ownerId: old.ownerId,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
      return true;
    }
    return false;
  }
}
