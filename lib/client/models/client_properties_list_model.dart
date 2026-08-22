// class ClientPropertiesListModel {
//   final bool status;
//   final String message;
//   final List<ClientProperty> data;
//   final dynamic errors;
//
//   ClientPropertiesListModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientPropertiesListModel.fromJson(Map<String, dynamic> json) {
//     return ClientPropertiesListModel(
//       status: json['status'] ?? false,
//       message: json['message']?.toString() ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientProperty.fromJson(Map<String, dynamic>.from(e)),
//           )
//           .toList(),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.map((e) => e.toJson()).toList(),
//       'errors': errors,
//     };
//   }
//
//   static List<ClientProperty> parsePropertyList(dynamic raw) {
//     if (raw == null) return [];
//
//     if (raw is List) {
//       return raw
//           .whereType<Map>()
//           .map((e) => ClientProperty.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     }
//
//     if (raw is Map) {
//       return [ClientProperty.fromJson(Map<String, dynamic>.from(raw))];
//     }
//
//     return [];
//   }
// }
//
// class ClientProperty {
//   final String propertyId;
//   final String propertyName;
//   final String address;
//   final String city;
//   final String propertyType;
//   final String monitoringStatus;
//   final String? verificationNotes;
//   final String? authorizationStatus;
//   final String? verifiedBy;
//   final String? verifiedAt;
//   final String? coordinatorId;
//   final String createdBy;
//   final String createdAt;
//   final String? updatedBy;
//   final String? updatedAt;
//   final String latitude;
//   final String longitude;
//   final String? propertyPhoto;
//   final String state;
//   final String plotSize;
//   final String sizeUnit;
//   final String plotDocuments;
//   final String plotType;
//   final String? coordinatorName;
//
//   ClientProperty({
//     required this.propertyId,
//     required this.propertyName,
//     required this.address,
//     required this.city,
//     required this.propertyType,
//     required this.monitoringStatus,
//     this.verificationNotes,
//     this.authorizationStatus,
//     this.verifiedBy,
//     this.verifiedAt,
//     this.coordinatorId,
//     required this.createdBy,
//     required this.createdAt,
//     this.updatedBy,
//     this.updatedAt,
//     required this.latitude,
//     required this.longitude,
//     this.propertyPhoto,
//     required this.state,
//     required this.plotSize,
//     required this.sizeUnit,
//     required this.plotDocuments,
//     required this.plotType,
//     this.coordinatorName,
//   });
//
//   factory ClientProperty.fromJson(Map<String, dynamic> json) {
//     return ClientProperty(
//       propertyId: json['property_id']?.toString() ?? '',
//       propertyName: json['property_name']?.toString() ?? '',
//       address: json['address']?.toString() ?? '',
//       city: json['city']?.toString() ?? '',
//       propertyType: json['property_type']?.toString() ?? '',
//       monitoringStatus: json['monitoring_status']?.toString() ?? '',
//       verificationNotes: json['verification_notes']?.toString(),
//       authorizationStatus: json['authorization_status']?.toString(),
//       verifiedBy: json['verified_by']?.toString(),
//       verifiedAt: json['verified_at']?.toString(),
//       coordinatorId: json['coordinator_id']?.toString(),
//       createdBy: json['created_by']?.toString() ?? '',
//       createdAt: json['created_at']?.toString() ?? '',
//       updatedBy: json['updated_by']?.toString(),
//       updatedAt: json['updated_at']?.toString(),
//       latitude: json['latitude']?.toString() ?? '',
//       longitude: json['longitude']?.toString() ?? '',
//       propertyPhoto: json['property_photo']?.toString(),
//       state: json['state']?.toString() ?? '',
//       plotSize: json['plot_size']?.toString() ?? '',
//       sizeUnit: json['size_unit']?.toString() ?? '',
//       plotDocuments: json['plot_documents']?.toString() ?? '',
//       plotType: json['plot_type']?.toString() ?? '',
//       coordinatorName: json['coordinator_name']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'property_id': propertyId,
//       'property_name': propertyName,
//       'address': address,
//       'city': city,
//       'property_type': propertyType,
//       'monitoring_status': monitoringStatus,
//       'verification_notes': verificationNotes,
//       'authorization_status': authorizationStatus,
//       'verified_by': verifiedBy,
//       'verified_at': verifiedAt,
//       'coordinator_id': coordinatorId,
//       'created_by': createdBy,
//       'created_at': createdAt,
//       'updated_by': updatedBy,
//       'updated_at': updatedAt,
//       'latitude': latitude,
//       'longitude': longitude,
//       'property_photo': propertyPhoto,
//       'state': state,
//       'plot_size': plotSize,
//       'size_unit': sizeUnit,
//       'plot_documents': plotDocuments,
//       'plot_type': plotType,
//       'coordinator_name': coordinatorName,
//     };
//   }
// }

class ClientPropertiesListModel {
  final bool status;
  final String message;
  final List<ClientProperty> data;
  final dynamic errors;

  ClientPropertiesListModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientPropertiesListModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientPropertiesListModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientPropertiesListModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: parsePropertyList(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'errors': errors,
    };
  }

  static bool _parseStatus(dynamic raw) {
    if (raw == null) return false;

    if (raw is bool) return raw;

    if (raw is num) {
      return raw == 1 || raw == 200;
    }

    if (raw is String) {
      final value = raw.trim().toLowerCase();

      return value == 'true' ||
          value == '1' ||
          value == '200' ||
          value == 'success';
    }

    return false;
  }

  static List<ClientProperty> parsePropertyList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientProperty.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientProperty.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientProperty {
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
  final String? propertyPhoto;
  final String state;
  final String plotSize;
  final String sizeUnit;
  final String plotDocuments;
  final String plotType;
  final String? coordinatorName;

  ClientProperty({
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
    this.propertyPhoto,
    required this.state,
    required this.plotSize,
    required this.sizeUnit,
    required this.plotDocuments,
    required this.plotType,
    this.coordinatorName,
  });

  factory ClientProperty.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientProperty(
        propertyId: '',
        propertyName: '',
        address: '',
        city: '',
        propertyType: '',
        monitoringStatus: '',
        verificationNotes: null,
        authorizationStatus: null,
        verifiedBy: null,
        verifiedAt: null,
        coordinatorId: null,
        createdBy: '',
        createdAt: '',
        updatedBy: null,
        updatedAt: null,
        latitude: '',
        longitude: '',
        propertyPhoto: null,
        state: '',
        plotSize: '',
        sizeUnit: '',
        plotDocuments: '',
        plotType: '',
        coordinatorName: null,
      );
    }

    return ClientProperty(
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
      propertyPhoto: json['property_photo']?.toString(),
      state: json['state']?.toString() ?? '',
      plotSize: json['plot_size']?.toString() ?? '',
      sizeUnit: json['size_unit']?.toString() ?? '',
      plotDocuments: json['plot_documents']?.toString() ?? '',
      plotType: json['plot_type']?.toString() ?? '',
      coordinatorName: json['coordinator_name']?.toString(),
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