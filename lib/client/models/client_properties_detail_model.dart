// class ClientPropertiesDetailModel {
//   final bool status;
//   final String message;
//   final ClientPropertyDetailData data;
//   final dynamic errors;
//
//   ClientPropertiesDetailModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientPropertiesDetailModel.fromJson(Map<String, dynamic> json) {
//     return ClientPropertiesDetailModel(
//       status: json['status'] ?? false,
//       message: json['message']?.toString() ?? '',
//       data: ClientPropertyDetailData.fromJson(
//         _mapFromDynamic(json['data']) ?? const {},
//       ),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.toJson(),
//       'errors': errors,
//     };
//   }
//
//   static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
//     if (raw is Map<String, dynamic>) return raw;
//     if (raw is Map) return Map<String, dynamic>.from(raw);
//     return null;
//   }
// }
//
// class ClientPropertyDetailData {
//   final ClientPropertyDetail property;
//   final List<ClientPropertyImage> images;
//
//   ClientPropertyDetailData({
//     required this.property,
//     required this.images,
//   });
//
//   factory ClientPropertyDetailData.fromJson(Map<String, dynamic> json) {
//     final nestedProperty = ClientPropertiesDetailModel._mapFromDynamic(
//       json['property'],
//     );
//
//     return ClientPropertyDetailData(
//       property: nestedProperty != null
//           ? ClientPropertyDetail.fromJson(nestedProperty)
//           : ClientPropertyDetail.fromJson(const {}),
//       images: (json['images'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientPropertyImage.fromJson(Map<String, dynamic>.from(e)),
//           )
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'property': property.toJson(),
//       'images': images.map((e) => e.toJson()).toList(),
//     };
//   }
// }
//
// class ClientPropertyDetail {
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
//   final String propertyPhoto;
//   final String state;
//   final String plotSize;
//   final String sizeUnit;
//   final String plotDocuments;
//   final String plotType;
//
//   ClientPropertyDetail({
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
//     required this.propertyPhoto,
//     required this.state,
//     required this.plotSize,
//     required this.sizeUnit,
//     required this.plotDocuments,
//     required this.plotType,
//   });
//
//   factory ClientPropertyDetail.fromJson(Map<String, dynamic> json) {
//     return ClientPropertyDetail(
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
//       propertyPhoto: json['property_photo']?.toString() ?? '',
//       state: json['state']?.toString() ?? '',
//       plotSize: json['plot_size']?.toString() ?? '',
//       sizeUnit: json['size_unit']?.toString() ?? '',
//       plotDocuments: json['plot_documents']?.toString() ?? '',
//       plotType: json['plot_type']?.toString() ?? '',
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
//     };
//   }
// }
//
// class ClientPropertyImage {
//   final String imageId;
//   final String propertyId;
//   final String imagePath;
//   final String isPrimary;
//   final String createdAt;
//
//   ClientPropertyImage({
//     required this.imageId,
//     required this.propertyId,
//     required this.imagePath,
//     required this.isPrimary,
//     required this.createdAt,
//   });
//
//   factory ClientPropertyImage.fromJson(Map<String, dynamic> json) {
//     return ClientPropertyImage(
//       imageId: json['image_id']?.toString() ?? '',
//       propertyId: json['property_id']?.toString() ?? '',
//       imagePath: json['image_path']?.toString() ?? '',
//       isPrimary: json['is_primary']?.toString() ?? '',
//       createdAt: json['created_at']?.toString() ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'image_id': imageId,
//       'property_id': propertyId,
//       'image_path': imagePath,
//       'is_primary': isPrimary,
//       'created_at': createdAt,
//     };
//   }
// }


class ClientPropertiesDetailModel {
  final bool status;
  final String message;
  final ClientPropertyDetailData data;
  final dynamic errors;

  ClientPropertiesDetailModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientPropertiesDetailModel.fromJson(Map<String, dynamic> json) {
    return ClientPropertiesDetailModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ClientPropertyDetailData.fromJson(json['data'] ?? {}),
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
}

class ClientPropertyDetailData {
  final ClientPropertyDetail property;
  final List<ClientPropertyImage> images;
  final AccountManager accountManager;

  ClientPropertyDetailData({
    required this.property,
    required this.images,
    required this.accountManager,
  });

  factory ClientPropertyDetailData.fromJson(Map<String, dynamic> json) {
    return ClientPropertyDetailData(
      property: ClientPropertyDetail.fromJson(json['property'] ?? {}),
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ClientPropertyImage.fromJson(e))
          .toList(),
      accountManager:
      AccountManager.fromJson(json['account_manager'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property': property.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'account_manager': accountManager.toJson(),
    };
  }
}

class ClientPropertyDetail {
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

  ClientPropertyDetail({
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

  factory ClientPropertyDetail.fromJson(Map<String, dynamic> json) {
    return ClientPropertyDetail(
      propertyId: json['property_id'] ?? '',
      propertyName: json['property_name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      propertyType: json['property_type'] ?? '',
      monitoringStatus: json['monitoring_status'] ?? '',
      verificationNotes: json['verification_notes'],
      authorizationStatus: json['authorization_status'],
      verifiedBy: json['verified_by'],
      verifiedAt: json['verified_at'],
      coordinatorId: json['coordinator_id'],
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedBy: json['updated_by'],
      updatedAt: json['updated_at'],
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      propertyPhoto: json['property_photo'] ?? '',
      state: json['state'] ?? '',
      plotSize: json['plot_size'] ?? '',
      sizeUnit: json['size_unit'] ?? '',
      plotDocuments: json['plot_documents'] ?? '',
      plotType: json['plot_type'] ?? '',
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

class ClientPropertyImage {
  final String imageId;
  final String propertyId;
  final String imagePath;
  final String isPrimary;
  final String createdAt;

  ClientPropertyImage({
    required this.imageId,
    required this.propertyId,
    required this.imagePath,
    required this.isPrimary,
    required this.createdAt,
  });

  factory ClientPropertyImage.fromJson(Map<String, dynamic> json) {
    return ClientPropertyImage(
      imageId: json['image_id'] ?? '',
      propertyId: json['property_id'] ?? '',
      imagePath: json['image_path'] ?? '',
      isPrimary: json['is_primary'] ?? '',
      createdAt: json['created_at'] ?? '',
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

class AccountManager {
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String role;
  final String profileImageUrl;

  AccountManager({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.role,
    required this.profileImageUrl,
  });

  factory AccountManager.fromJson(Map<String, dynamic> json) {
    return AccountManager(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profile_image'],
      role: json['role'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'role': role,
      'profile_image_url': profileImageUrl,
    };
  }
}