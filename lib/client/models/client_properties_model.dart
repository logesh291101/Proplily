class ClientPropertiesModel {
  final bool? status;
  final String? message;
  final List<ClientProperty>? data;
  final dynamic errors;

  ClientPropertiesModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory ClientPropertiesModel.fromJson(Map<String, dynamic> json) {
    return ClientPropertiesModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .whereType<Map>()
              .map((e) => ClientProperty.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <ClientProperty>[],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }
}

class ClientProperty {
  final String? propertyId;
  final String? propertyName;
  final String? address;
  final String? city;
  final String? propertyType;
  final String? monitoringStatus;
  final String? verificationNotes;
  final String? authorizationStatus;
  final String? verifiedBy;
  final String? verifiedAt;
  final String? coordinatorId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String? latitude;
  final String? longitude;
  final String? propertyPhoto;
  final String? state;
  final String? plotSize;
  final String? sizeUnit;
  final String? plotDocuments;
  final String? plotType;
  final String? coordinatorName;

  ClientProperty({
    this.propertyId,
    this.propertyName,
    this.address,
    this.city,
    this.propertyType,
    this.monitoringStatus,
    this.verificationNotes,
    this.authorizationStatus,
    this.verifiedBy,
    this.verifiedAt,
    this.coordinatorId,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.propertyPhoto,
    this.state,
    this.plotSize,
    this.sizeUnit,
    this.plotDocuments,
    this.plotType,
    this.coordinatorName,
  });

  factory ClientProperty.fromJson(Map<String, dynamic> json) {
    return ClientProperty(
      propertyId: json['property_id']?.toString(),
      propertyName: json['property_name'],
      address: json['address'],
      city: json['city'],
      propertyType: json['property_type'],
      monitoringStatus: json['monitoring_status'],
      verificationNotes: json['verification_notes'],
      authorizationStatus: json['authorization_status'],
      verifiedBy: json['verified_by']?.toString(),
      verifiedAt: json['verified_at'],
      coordinatorId: json['coordinator_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      propertyPhoto: json['property_photo'],
      state: json['state'],
      plotSize: json['plot_size'],
      sizeUnit: json['size_unit'],
      plotDocuments: json['plot_documents'],
      plotType: json['plot_type'],
      coordinatorName: json['coordinator_name'],
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
      'coordinator_name': coordinatorName,
    };
  }
}
