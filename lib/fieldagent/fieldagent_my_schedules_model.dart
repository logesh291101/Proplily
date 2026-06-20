import 'dart:convert';

/// API response for `GET {live_url}/coordinator_api/properties`.
class FieldAgentMySchedulesModel {
  final bool? status;
  final String? message;
  final List<PropertyData>? data;
  final dynamic errors;

  FieldAgentMySchedulesModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory FieldAgentMySchedulesModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentMySchedulesModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: _parseProperties(json['data']),
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

  bool get isSuccess => status == true;

  static bool? _parseStatus(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      if (t == '200' || t == 'true') return true;
      if (t == 'false') return false;
    }
    return null;
  }

  static List<PropertyData> _parseProperties(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => PropertyData.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      for (final key in ['properties', 'items', 'list']) {
        if (map[key] != null) {
          return _parseProperties(map[key]);
        }
      }
    }

    return [];
  }
}

class PropertyData {
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
  final String? accountManagerName;
  final String? accountManagerPhone;
  final String? accountManagerEmail;
  final List<String> propertyImages;

  PropertyData({
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
    this.accountManagerName,
    this.accountManagerPhone,
    this.accountManagerEmail,
    List<String>? propertyImages,
  }) : propertyImages = propertyImages ?? const [];

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    final accountManager = _readMap(json['account_manager']);

    return PropertyData(
      propertyId: _stringOrNull(json['property_id']),
      propertyName: _stringOrNull(json['property_name']),
      address: _stringOrNull(json['address']),
      city: _stringOrNull(json['city']),
      propertyType: _stringOrNull(json['property_type']),
      monitoringStatus: _stringOrNull(json['monitoring_status']),
      verificationNotes: _stringOrNull(json['verification_notes']),
      authorizationStatus: _stringOrNull(json['authorization_status']),
      verifiedBy: _stringOrNull(json['verified_by']),
      verifiedAt: _stringOrNull(json['verified_at']),
      coordinatorId: _stringOrNull(json['coordinator_id']),
      createdBy: _stringOrNull(json['created_by']),
      createdAt: _stringOrNull(json['created_at']),
      updatedBy: _stringOrNull(json['updated_by']),
      updatedAt: _stringOrNull(json['updated_at']),
      latitude: _stringOrNull(json['latitude']),
      longitude: _stringOrNull(json['longitude']),
      propertyPhoto: _stringOrNull(json['property_photo']),
      state: _stringOrNull(json['state']),
      plotSize: _stringOrNull(json['plot_size']),
      sizeUnit: _stringOrNull(json['size_unit']),
      plotDocuments: _stringOrNull(json['plot_documents']),
      plotType: _stringOrNull(json['plot_type']),
      accountManagerName: _firstNonEmpty([
        _stringOrNull(json['account_manager_name']),
        _stringOrNull(json['am_name']),
        _stringOrNull(json['manager_name']),
        _stringOrNull(accountManager?['name']),
        _stringOrNull(accountManager?['manager_name']),
        _stringOrNull(accountManager?['account_manager_name']),
      ]),
      accountManagerPhone: _firstNonEmpty([
        _stringOrNull(json['account_manager_phone']),
        _stringOrNull(json['am_phone']),
        _stringOrNull(json['manager_phone']),
        _stringOrNull(json['phone']),
        _stringOrNull(accountManager?['phone']),
        _stringOrNull(accountManager?['phone_number']),
      ]),
      accountManagerEmail: _firstNonEmpty([
        _stringOrNull(json['account_manager_email']),
        _stringOrNull(json['am_email']),
        _stringOrNull(json['manager_email']),
        _stringOrNull(json['email']),
        _stringOrNull(accountManager?['email']),
        _stringOrNull(accountManager?['email_address']),
      ]),
      propertyImages: _parseImages(
        propertyPhoto: json['property_photo'],
        images: json['property_images'] ?? json['images'],
      ),
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
      'account_manager_name': accountManagerName,
      'account_manager_phone': accountManagerPhone,
      'account_manager_email': accountManagerEmail,
      'property_images': propertyImages,
    };
  }

  String get locationLine {
    final parts = [address?.trim(), city?.trim()]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  String get accountManagerDisplay {
    final name = accountManagerName?.trim();
    if (name == null || name.isEmpty) return '—';
    return '$name (AM)';
  }

  String get plotSizeDisplay {
    final size = plotSize?.trim();
    if (size == null || size.isEmpty) return '—';
    final unit = sizeUnit?.trim();
    if (unit == null || unit.isEmpty) return size;
    return '$size $unit';
  }

  List<String> get imageUrls {
    if (propertyImages.isNotEmpty) return propertyImages;
    final photo = propertyPhoto?.trim();
    if (photo == null || photo.isEmpty) return const [];
    return _parseImages(propertyPhoto: photo);
  }

  bool get hasMapCoordinates {
    final lat = latitude?.trim();
    final lng = longitude?.trim();
    if (lat == null || lat.isEmpty || lng == null || lng.isEmpty) {
      return false;
    }
    if (lat == '0' || lng == '0') return false;

    final latValue = double.tryParse(lat);
    final lngValue = double.tryParse(lng);
    if (latValue == null || lngValue == null) return false;
    if (latValue == 0 || lngValue == 0) return false;

    return true;
  }

  Uri? get mapsUri {
    if (!hasMapCoordinates) return null;
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${latitude!.trim()},${longitude!.trim()}',
    );
  }

  Uri? get openStreetMapUri {
    if (!hasMapCoordinates) return null;
    final lat = latitude!.trim();
    final lng = longitude!.trim();
    return Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng',
    );
  }

  Uri? get callUri {
    final phone = accountManagerPhone?.trim();
    if (phone == null || phone.isEmpty) return null;
    return Uri(scheme: 'tel', path: phone);
  }

  Uri? get emailUri {
    final email = accountManagerEmail?.trim();
    if (email == null || email.isEmpty) return null;
    return Uri(scheme: 'mailto', path: email);
  }

  List<({String label, String value})> get recordEntries {
    final entries = <({String label, String? value})>[
      (label: 'Type', value: propertyType),
      (label: 'State', value: state),
      (label: 'Plot Type', value: plotType),
      (label: 'Plot Size', value: plotSizeDisplay == '—' ? null : plotSizeDisplay),
      (label: 'Latitude', value: latitude),
      (label: 'Longitude', value: longitude),
      // (label: 'Monitoring Status', value: monitoringStatus),
      // (label: 'Authorization Status', value: authorizationStatus),
      // (label: 'Verification Notes', value: verificationNotes),
      // (label: 'Verified By', value: verifiedBy),
      // (label: 'Verified At', value: verifiedAt),
      // (label: 'Created At', value: createdAt),
      // (label: 'Updated At', value: updatedAt),
    ];

    return entries
        .where((entry) => entry.value?.trim().isNotEmpty == true)
        .map((entry) => (label: entry.label, value: entry.value!.trim()))
        .toList();
  }

  static String? _stringOrNull(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    return raw.toString();
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static Map<String, dynamic>? _readMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static List<String> _parseImages({
    dynamic propertyPhoto,
    dynamic images,
  }) {
    final urls = <String>[];

    void addUrl(String? raw) {
      final trimmed = raw?.trim();
      if (trimmed != null && trimmed.isNotEmpty && !urls.contains(trimmed)) {
        urls.add(trimmed);
      }
    }

    if (images is List) {
      for (final item in images) {
        if (item is Map) {
          addUrl(_stringOrNull(item['url']) ?? _stringOrNull(item['image']));
        } else {
          addUrl(_stringOrNull(item));
        }
      }
    } else if (images is String && images.trim().isNotEmpty) {
      _addUrlsFromString(images, addUrl);
    }

    if (propertyPhoto != null) {
      if (propertyPhoto is List) {
        for (final item in propertyPhoto) {
          addUrl(_stringOrNull(item));
        }
      } else if (propertyPhoto is String) {
        _addUrlsFromString(propertyPhoto, addUrl);
      }
    }

    return urls;
  }

  static void _addUrlsFromString(String raw, void Function(String?) addUrl) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;

    if (trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is List) {
          for (final item in decoded) {
            addUrl(_stringOrNull(item));
          }
          return;
        }
      } catch (_) {}
    }

    if (trimmed.contains(',')) {
      for (final part in trimmed.split(',')) {
        addUrl(part);
      }
      return;
    }

    addUrl(trimmed);
  }
}
