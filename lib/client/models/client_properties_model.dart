class ClientPropertiesModel {
  final bool status;
  final String message;
  final ClientPropertyData data;
  final dynamic errors;

  ClientPropertiesModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientPropertiesModel.fromJson(Map<String, dynamic> json) {
    return ClientPropertiesModel(
      status: json['status'] ?? false,
      message: json['message']?.toString() ?? '',
      data: ClientPropertyData.fromJson(
        _mapFromDynamic(json['data']) ?? const {},
      ),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
      'errors': errors,
    };
  }

  static List<ClientPropertyData> parsePropertyDataList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map(_mapFromDynamic)
          .whereType<Map<String, dynamic>>()
          .map(ClientPropertyData.fromJson)
          .toList();
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map.containsKey('property') || map.containsKey('images')) {
        return [ClientPropertyData.fromJson(map)];
      }
      if (_isFlatPropertyMap(map)) {
        return [ClientPropertyData.fromJson(map)];
      }
    }

    return [];
  }

  static bool _isFlatPropertyMap(Map<String, dynamic> json) {
    return json.containsKey('property_id') ||
        json.containsKey('property_name') ||
        json.containsKey('property_type');
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}

class ClientPropertyData {
  final Property property;
  final List<PropertyImage> images;

  ClientPropertyData({
    required this.property,
    required this.images,
  });

  factory ClientPropertyData.fromJson(Map<String, dynamic> json) {
    final nestedProperty = ClientPropertiesModel._mapFromDynamic(json['property']);
    if (nestedProperty != null) {
      return ClientPropertyData(
        property: Property.fromJson(nestedProperty),
        images: _parseImages(json['images']),
      );
    }

    if (ClientPropertiesModel._isFlatPropertyMap(json)) {
      return ClientPropertyData(
        property: Property.fromJson(json),
        images: _parseImages(json['images']),
      );
    }

    return ClientPropertyData(
      property: Property.fromJson(const {}),
      images: const [],
    );
  }

  static List<PropertyImage> _parseImages(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .map(ClientPropertyData._mapFromDynamic)
        .whereType<Map<String, dynamic>>()
        .map(PropertyImage.fromJson)
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'property': property.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}

class Property {
  final String propertyId;
  final String propertyName;
  final String address;
  final String city;
  final String propertyType;
  final String monitoringStatus;
  final String? verificationNotes;
  final String? authorizationStatus;
  final String? verifiedBy;
  final String? verifiedAt;
  final String? coordinatorId;
  final String createdBy;
  final String createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String latitude;
  final String longitude;
  final String propertyPhoto;
  final String state;
  final String plotSize;
  final String sizeUnit;
  final String plotDocuments;
  final String plotType;

  Property({
    required this.propertyId,
    required this.propertyName,
    required this.address,
    required this.city,
    required this.propertyType,
    required this.monitoringStatus,
    this.verificationNotes,
    this.authorizationStatus,
    this.verifiedBy,
    this.verifiedAt,
    this.coordinatorId,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    required this.latitude,
    required this.longitude,
    required this.propertyPhoto,
    required this.state,
    required this.plotSize,
    required this.sizeUnit,
    required this.plotDocuments,
    required this.plotType,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      propertyId: json['property_id']?.toString() ?? '',
      propertyName: json['property_name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      monitoringStatus: json['monitoring_status']?.toString() ?? '',
      verificationNotes: json['verification_notes']?.toString(),
      authorizationStatus: json['authorization_status']?.toString(),
      verifiedBy: json['verified_by']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
      coordinatorId: json['coordinator_id']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      propertyPhoto: json['property_photo']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      plotSize: json['plot_size']?.toString() ?? '',
      sizeUnit: json['size_unit']?.toString() ?? '',
      plotDocuments: json['plot_documents']?.toString() ?? '',
      plotType: json['plot_type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'property_name': propertyName,
      'address': address,
      'city': city,
      'property_type': propertyType,
      'monitoring_status': monitoringStatus,
      'verification_notes': verificationNotes,
      'authorization_status': authorizationStatus,
      'verified_by': verifiedBy,
      'verified_at': verifiedAt,
      'coordinator_id': coordinatorId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'latitude': latitude,
      'longitude': longitude,
      'property_photo': propertyPhoto,
      'state': state,
      'plot_size': plotSize,
      'size_unit': sizeUnit,
      'plot_documents': plotDocuments,
      'plot_type': plotType,
    };
  }
}

class PropertyImage {
  final String imageId;
  final String propertyId;
  final String imagePath;
  final String isPrimary;
  final String createdAt;

  PropertyImage({
    required this.imageId,
    required this.propertyId,
    required this.imagePath,
    required this.isPrimary,
    required this.createdAt,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      imageId: json['image_id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      isPrimary: json['is_primary']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'property_id': propertyId,
      'image_path': imagePath,
      'is_primary': isPrimary,
      'created_at': createdAt,
    };
  }
}

/// Backward-compatible alias used during the [ClientProperty] → [ClientPropertyData] migration.
typedef ClientProperty = ClientPropertyData;
