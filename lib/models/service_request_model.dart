import 'property_model.dart';

enum ServiceRequestType {
  documentation,
  brokering,
  emergency,
}

enum ServiceRequestStatus {
  requested,
  pendingVerification,
  approved,
  assigned,
  inProgress,
  completed,
  rejected,
}

class ServiceRequest {
  final String id;
  final ServiceRequestType requestType;
  final String? propertyName;
  final PropertyType? propertyType;
  final String? propertyAddress;
  final String? city;
  final String? ownerName;
  final String? contactNumber;
  final double? latitude;
  final double? longitude;
  final String? propertyPhoto;
  final String? description;
  final bool isEmergency;
  final ServiceRequestStatus status;
  final String? assignedToId;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceRequest({
    required this.id,
    required this.requestType,
    this.propertyName,
    this.propertyType,
    this.propertyAddress,
    this.city,
    required this.ownerName,
    required this.contactNumber,
    this.latitude,
    this.longitude,
    this.propertyPhoto,
    this.description,
    this.isEmergency = false,
    this.status = ServiceRequestStatus.requested,
    this.assignedToId,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id']?.toString() ?? '',
      requestType: ServiceRequestType.values.firstWhere(
        (e) => e.toString().split('.').last == json['requestType'],
        orElse: () => ServiceRequestType.documentation,
      ),
      propertyName: json['propertyName'] as String?,
      propertyType: json['propertyType'] != null
          ? PropertyType.values.firstWhere(
              (e) => e.toString().split('.').last == json['propertyType'],
              orElse: () => PropertyType.land,
            )
          : null,
      ownerName: json['ownerName'] as String? ?? 'N/A',
      contactNumber: json['contactNumber'] as String? ?? 'N/A',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      propertyPhoto: json['propertyPhoto'] as String?,
      description: json['description'] as String?,
      isEmergency: json['isEmergency'] as bool? ?? false,
      status: ServiceRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ServiceRequestStatus.requested,
      ),
      assignedToId: json['assignedToId'] as String?,
      ownerId: json['ownerId']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestType': requestType.toString().split('.').last,
      'propertyName': propertyName,
      'propertyType':
          propertyType?.toString().split('.').last,
      'propertyAddress': propertyAddress,
      'city': city,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'latitude': latitude,
      'longitude': longitude,
      'propertyPhoto': propertyPhoto,
      'propertyPhoto': propertyPhoto,
      'description': description,
      'isEmergency': isEmergency,
      'status': status.toString().split('.').last,
      'assignedToId': assignedToId,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
