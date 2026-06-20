class ClientPropertyStatusModel {
  final bool status;
  final String message;
  final List<ClientPropertyStatusItem> data;
  final dynamic errors;

  ClientPropertyStatusModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientPropertyStatusModel.fromJson(Map<String, dynamic> json) {
    return ClientPropertyStatusModel(
      status: _parseStatus(json['status']),
      message: _parseString(json['message']),
      data: parsePropertyStatusList(json['data']),
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
    if (raw is bool) return raw;
    if (raw is int) return raw == 200;
    if (raw is num) return raw == 200;
    if (raw is String) {
      final t = raw.trim().toLowerCase();
      return t == '200' || t == 'true';
    }
    return false;
  }

  static List<ClientPropertyStatusItem> parsePropertyStatusList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .map(_mapFromDynamic)
          .whereType<Map<String, dynamic>>()
          .map(ClientPropertyStatusItem.fromJson)
          .toList();
    }

    if (raw is Map) {
      final map = _mapFromDynamic(raw);
      if (map == null) return [];
      return [ClientPropertyStatusItem.fromJson(map)];
    }

    return [];
  }

  static Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static String _parseString(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    return raw.toString();
  }
}

/// One property record from `GET /user/properties/status`.
class ClientPropertyStatusItem {
  const ClientPropertyStatusItem({
    required this.propertyId,
    required this.propertyName,
    required this.propertyType,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.plotSize,
    required this.latitude,
    required this.longitude,
    required this.ownerName,
    required this.ownerPhone,
    required this.monitoringStatus,
    required this.authorizationStatus,
    required this.createdAt,
  });

  final String propertyId;
  final String propertyName;
  final String propertyType;
  final String address;
  final String city;
  final String country;
  final String state;
  final String plotSize;
  final String latitude;
  final String longitude;
  final String ownerName;
  final String ownerPhone;
  final String monitoringStatus;
  final String authorizationStatus;
  final String createdAt;

  factory ClientPropertyStatusItem.fromJson(Map<String, dynamic> json) {
    return ClientPropertyStatusItem(
      propertyId: _parseString(_read(json, ['property_id', 'propertyId', 'id'])),
      propertyName:
          _parseString(_read(json, ['property_name', 'propertyName', 'name'])),
      propertyType: _parseString(
        _read(json, ['property_type', 'propertyType', 'type']),
      ),
      address: _parseString(_read(json, ['address', 'property_address'])),
      city: _parseString(_read(json, ['city', 'property_city'])),
      country: _parseString(_read(json, ['country', 'property_country'])),
      state: _parseString(_read(json, ['state', 'property_state'])),
      plotSize: _parseString(_read(json, ['plot_size', 'plotSize', 'size'])),
      latitude: _parseString(_read(json, ['latitude', 'lat'])),
      longitude: _parseString(_read(json, ['longitude', 'lng', 'lon'])),
      ownerName: _parseString(
        _read(json, ['owner_name', 'ownerName', 'owner']),
      ),
      ownerPhone: _parseString(
        _read(json, ['owner_phone', 'ownerPhone', 'phone', 'phone_number']),
      ),
      monitoringStatus: _parseString(
        _read(json, [
          'monitoring_status',
          'monitoringStatus',
          'monitoring',
        ]),
      ),
      authorizationStatus: _parseString(
        _read(json, [
          'authorization_status',
          'authorizationStatus',
          'authorization',
        ]),
      ),
      createdAt:
          _parseString(_read(json, ['created_at', 'createdAt', 'created'])),
    );
  }

  static dynamic _read(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }
    return null;
  }

  static String _parseString(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    return raw.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'property_name': propertyName,
      'property_type': propertyType,
      'address': address,
      'city': city,
      'country': country,
      'state': state,
      'plot_size': plotSize,
      'latitude': latitude,
      'longitude': longitude,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'monitoring_status': monitoringStatus,
      'authorization_status': authorizationStatus,
      'created_at': createdAt,
    };
  }
}

/// @deprecated Use [ClientPropertyStatusItem]. Kept for hot-reload migration only.
typedef PropertyStatus = ClientPropertyStatusItem;
