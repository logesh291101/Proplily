enum PropertyType {
  land,
  independentHouse,
  apartment,
  flat,
}

enum PropertyStatus {
  pendingVerification,
  approved,
  rejected,
}

class Property {
  final String id;
  final String propertyName;
  final PropertyType propertyType;
  final String propertyAddress;
  final String ownerName;
  final String contactNumber;
  final double latitude;
  final double longitude;
  final List<String> documentUrls;
  final List<String> propertyImages;
  final PropertyStatus status;
  final String? rejectionReason;
  final String ownerId;
  final String? assignedCoordinatorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.propertyName,
    required this.propertyType,
    required this.propertyAddress,
    required this.ownerName,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    this.documentUrls = const [],
    this.propertyImages = const [],
    this.status = PropertyStatus.pendingVerification,
    this.rejectionReason,
    required this.ownerId,
    this.assignedCoordinatorId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      propertyName: json['propertyName'] as String,
      propertyType: PropertyType.values.firstWhere(
        (e) => e.toString().split('.').last == json['propertyType'],
        orElse: () => PropertyType.land,
      ),
      propertyAddress: json['propertyAddress'] as String,
      ownerName: json['ownerName'] as String,
      contactNumber: json['contactNumber'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      documentUrls: List<String>.from(json['documentUrls'] as List? ?? []),
      propertyImages: List<String>.from(json['propertyImages'] as List? ?? []),
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PropertyStatus.pendingVerification,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      ownerId: json['ownerId'] as String,
      assignedCoordinatorId: json['assignedCoordinatorId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyName': propertyName,
      'propertyType': propertyType.toString().split('.').last,
      'propertyAddress': propertyAddress,
      'ownerName': ownerName,
      'contactNumber': contactNumber,
      'latitude': latitude,
      'longitude': longitude,
      'documentUrls': documentUrls,
      'propertyImages': propertyImages,
      'status': status.toString().split('.').last,
      'rejectionReason': rejectionReason,
      'ownerId': ownerId,
      'assignedCoordinatorId': assignedCoordinatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
