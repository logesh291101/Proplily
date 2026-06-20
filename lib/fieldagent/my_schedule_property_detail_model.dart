import 'dart:convert';

/// API response for `GET {live_url}/coordinator_api/tasks/{task_id}`.
class MySchedulePropertyDetailModel {
  MySchedulePropertyDetailModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  final bool? status;
  final String? message;
  final MySchedulePropertyDetail? data;
  final dynamic errors;

  factory MySchedulePropertyDetailModel.fromJson(Map<String, dynamic> json) {
    return MySchedulePropertyDetailModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: _parseDetail(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
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

  static MySchedulePropertyDetail? _parseDetail(dynamic raw) {
    if (raw == null) return null;

    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map['property'] is Map) {
        return MySchedulePropertyDetail.fromJson(
          Map<String, dynamic>.from(map['property'] as Map),
          task: map,
        );
      }
      return MySchedulePropertyDetail.fromJson(map);
    }

    return null;
  }
}

class MySchedulePropertyDetail {
  MySchedulePropertyDetail({
    this.taskId,
    this.propertyId,
    this.propertyName,
    this.address,
    this.city,
    this.status,
    this.visitType,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.priority,
    this.propertyType,
    this.plotType,
    this.plotSize,
    this.sizeUnit,
    this.state,
    this.latitude,
    this.longitude,
    this.propertyPhoto,
    this.accountManagerName,
    this.accountManagerPhone,
    this.accountManagerEmail,
    List<String>? propertyImages,
  }) : propertyImages = propertyImages ?? const [];

  final String? taskId;
  final String? propertyId;
  final String? propertyName;
  final String? address;
  final String? city;
  final String? status;
  final String? visitType;
  final String? scheduledDate;
  final String? startTime;
  final String? endTime;
  final String? priority;
  final String? propertyType;
  final String? plotType;
  final String? plotSize;
  final String? sizeUnit;
  final String? state;
  final String? latitude;
  final String? longitude;
  final String? propertyPhoto;
  final String? accountManagerName;
  final String? accountManagerPhone;
  final String? accountManagerEmail;
  final List<String> propertyImages;

  factory MySchedulePropertyDetail.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? task,
  }) {
    final taskMap = task ?? json;
    final propertyMap = json['property'] is Map
        ? Map<String, dynamic>.from(json['property'] as Map)
        : json;
    final accountManager = _readMap(
      json['account_manager'] ?? propertyMap['account_manager'],
    );

    return MySchedulePropertyDetail(
      taskId: _stringOrNull(taskMap['task_id']),
      propertyId: _stringOrNull(
        propertyMap['property_id'] ?? taskMap['property_id'],
      ),
      propertyName: _stringOrNull(
        propertyMap['property_name'] ?? taskMap['property_name'],
      ),
      address: _stringOrNull(propertyMap['address'] ?? taskMap['address']),
      city: _stringOrNull(propertyMap['city'] ?? taskMap['city']),
      status: _stringOrNull(taskMap['status'] ?? propertyMap['status']),
      visitType: _stringOrNull(taskMap['visit_type']),
      scheduledDate: _stringOrNull(taskMap['scheduled_date']),
      startTime: _stringOrNull(taskMap['start_time']),
      endTime: _stringOrNull(taskMap['end_time']),
      priority: _stringOrNull(taskMap['priority']),
      propertyType: _stringOrNull(propertyMap['property_type']),
      plotType: _stringOrNull(propertyMap['plot_type']),
      plotSize: _stringOrNull(propertyMap['plot_size']),
      sizeUnit: _stringOrNull(propertyMap['size_unit']),
      state: _stringOrNull(propertyMap['state']),
      latitude: _stringOrNull(propertyMap['latitude'] ?? taskMap['latitude']),
      longitude:
          _stringOrNull(propertyMap['longitude'] ?? taskMap['longitude']),
      propertyPhoto: _stringOrNull(propertyMap['property_photo']),
      accountManagerName: _firstNonEmpty([
        _stringOrNull(json['account_manager_name']),
        _stringOrNull(propertyMap['account_manager_name']),
        _stringOrNull(taskMap['account_manager_name']),
        _stringOrNull(accountManager?['name']),
        _stringOrNull(accountManager?['manager_name']),
      ]),
      accountManagerPhone: _firstNonEmpty([
        _stringOrNull(json['account_manager_phone']),
        _stringOrNull(propertyMap['account_manager_phone']),
        _stringOrNull(taskMap['account_manager_phone']),
        _stringOrNull(accountManager?['phone']),
        _stringOrNull(accountManager?['phone_number']),
      ]),
      accountManagerEmail: _firstNonEmpty([
        _stringOrNull(json['account_manager_email']),
        _stringOrNull(propertyMap['account_manager_email']),
        _stringOrNull(taskMap['account_manager_email']),
        _stringOrNull(accountManager?['email']),
        _stringOrNull(accountManager?['email_address']),
      ]),
      propertyImages: _parseImages(
        propertyPhoto: propertyMap['property_photo'] ?? taskMap['property_photo'],
        images: propertyMap['property_images'] ??
            propertyMap['images'] ??
            taskMap['property_images'] ??
            taskMap['images'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'property_id': propertyId,
      'property_name': propertyName,
      'address': address,
      'city': city,
      'status': status,
      'visit_type': visitType,
      'scheduled_date': scheduledDate,
      'start_time': startTime,
      'end_time': endTime,
      'priority': priority,
      'property_type': propertyType,
      'plot_type': plotType,
      'plot_size': plotSize,
      'size_unit': sizeUnit,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'property_photo': propertyPhoto,
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

  String get plotSizeDisplay {
    final size = plotSize?.trim();
    if (size == null || size.isEmpty) return '—';
    final unit = sizeUnit?.trim();
    if (unit == null || unit.isEmpty) return size;
    return '$size $unit';
  }

  String? get timeRange {
    final start = startTime?.trim();
    final end = endTime?.trim();
    if ((start == null || start.isEmpty) && (end == null || end.isEmpty)) {
      return null;
    }
    if (start != null &&
        start.isNotEmpty &&
        end != null &&
        end.isNotEmpty) {
      return '$start - $end';
    }
    return start ?? end;
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
    return lat != null &&
        lat.isNotEmpty &&
        lng != null &&
        lng.isNotEmpty &&
        double.tryParse(lat) != null &&
        double.tryParse(lng) != null;
  }

  Uri? get mapsUri {
    if (!hasMapCoordinates) return null;
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${latitude!.trim()},${longitude!.trim()}',
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

  List<({String label, String value})> get propertyDetailEntries {
    final entries = <({String label, String? value})>[
      (label: 'Property Type', value: propertyType),
      (label: 'Plot Type', value: plotType),
      (label: 'Plot Size', value: plotSizeDisplay == '—' ? null : plotSizeDisplay),
      (label: 'State', value: state),
      (label: 'Latitude', value: latitude),
      (label: 'Longitude', value: longitude),
    ];

    return entries
        .where((entry) => entry.value?.trim().isNotEmpty == true)
        .map((entry) => (label: entry.label, value: entry.value!.trim()))
        .toList();
  }

  List<({String label, String value})> get scheduleInfoEntries {
    final entries = <({String label, String? value})>[
      (label: 'Visit Type', value: visitType),
      (label: 'Scheduled Date', value: scheduledDate),
      // (label: 'Start Time', value: startTime),
      // (label: 'End Time', value: endTime),
      (label: 'Priority', value: priority),
      (label: 'Status', value: status),
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
