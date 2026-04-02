enum PropertyType {
  land,
  independentHouse,
  apartment,
  flat,
}

enum PropertyStatus {
  propertyAdded,
  pendingVerification,
  approved,
  rejected,
  cancelled,
}

extension PropertyStatusX on PropertyStatus {
  String get displayName {
    switch (this) {
      case PropertyStatus.propertyAdded:
      case PropertyStatus.pendingVerification:
        return 'Pending';
      case PropertyStatus.approved:
        return 'Approved';
      case PropertyStatus.rejected:
        return 'Rejected';
      case PropertyStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Property {
  final String id;
  final String propertyName;
  final PropertyType propertyType;
  final String propertyAddress;
  final String city;
  final double latitude;
  final double longitude;
  final String? propertyPhoto;
  final PropertyStatus status;
  final String ownerId;
  final String? assignedCoordinatorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.propertyName,
    required this.propertyType,
    required this.propertyAddress,
    this.city = '',
    required this.latitude,
    required this.longitude,
    this.propertyPhoto,
    this.status = PropertyStatus.propertyAdded,
    required this.ownerId,
    this.assignedCoordinatorId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id']?.toString() ?? '',
      propertyName: json['property_name'] ?? json['propertyName'] ?? '',
      propertyType: PropertyType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['property_type'] ?? json['propertyType']),
        orElse: () => PropertyType.land,
      ),
      propertyAddress: json['address'] ?? json['propertyAddress'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      propertyPhoto: json['property_photo'] ?? json['propertyPhoto'],
      status: PropertyStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PropertyStatus.propertyAdded,
      ),
      ownerId: json['owner_id']?.toString() ?? json['ownerId']?.toString() ?? '',
      assignedCoordinatorId: json['assigned_coordinator_id']?.toString() ?? json['assignedCoordinatorId']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : (json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_name': propertyName,
      'property_type': propertyType.toString().split('.').last,
      'address': propertyAddress,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'property_photo': propertyPhoto,
      'status': status.toString().split('.').last,
      'owner_id': ownerId,
      'assigned_coordinator_id': assignedCoordinatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
