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
  final String? ownerName;
  final String? contactNumber;
  final double? latitude;
  final double? longitude;
  final List<String> documentUrls;
  final List<String> propertyImages;
  final String? description;
  final bool isEmergency;
  final ServiceRequestStatus status;
  final String? rejectionReason;
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
    this.ownerName,
    this.contactNumber,
    this.latitude,
    this.longitude,
    this.documentUrls = const [],
    this.propertyImages = const [],
    this.description,
    this.isEmergency = false,
    this.status = ServiceRequestStatus.requested,
    this.rejectionReason,
    this.assignedToId,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
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
      propertyAddress: json['propertyAddress'] as String?,
      ownerName: json['ownerName'] as String?,
      contactNumber: json['contactNumber'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      documentUrls: List<String>.from(json['documentUrls'] as List? ?? []),
      propertyImages: List<String>.from(json['propertyImages'] as List? ?? []),
      description: json['description'] as String?,
      isEmergency: json['isEmergency'] as bool? ?? false,
      status: ServiceRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ServiceRequestStatus.requested,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      assignedToId: json['assignedToId'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'latitude': latitude,
      'longitude': longitude,
      'documentUrls': documentUrls,
      'propertyImages': propertyImages,
      'description': description,
      'isEmergency': isEmergency,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'assignedToId': assignedToId,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
