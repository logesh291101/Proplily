class MySchedulePropertyDetailModel {
  final bool status;
  final String message;
  final MySchedulePropertyDetail data;
  final dynamic errors;

  MySchedulePropertyDetailModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory MySchedulePropertyDetailModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return MySchedulePropertyDetailModel(
      status: _parseStatus(json['status']),
      message: '${json['message'] ?? ''}',
      data: MySchedulePropertyDetail.fromJson(dataMap),
      errors: json['errors'],
    );
  }

  static bool _parseStatus(dynamic raw) {
    if (raw == true || raw == 1) return true;
    if (raw == false || raw == 0 || raw == null) return false;
    final text = '$raw'.trim().toLowerCase();
    return text == 'true' || text == '1' || text == '200' || text == 'success';
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

class MySchedulePropertyDetail {
  final String taskId;
  final String assignmentId;
  final String propertyId;
  final String fieldAgentId;
  final String assignedBy;
  final String visitType;
  final String scheduledDate;
  final String startTime;
  final String endTime;
  final String priority;
  final String isRecurring;
  final String parentTaskId;
  final String status;
  final String assignmentTimestamp;
  final String? startedAt;
  final String? completedAt;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  final String propertyName;
  final String address;
  final String city;
  final String propertyLat;
  final String propertyLng;
  final String accountManagerName;
  final String accountManagerPhone;
  final String accountManagerEmail;

  MySchedulePropertyDetail({
    required this.taskId,
    required this.assignmentId,
    required this.propertyId,
    required this.fieldAgentId,
    required this.assignedBy,
    required this.visitType,
    required this.scheduledDate,
    required this.startTime,
    required this.endTime,
    required this.priority,
    required this.isRecurring,
    required this.parentTaskId,
    required this.status,
    required this.assignmentTimestamp,
    this.startedAt,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.propertyName,
    required this.address,
    required this.city,
    required this.propertyLat,
    required this.propertyLng,
    required this.accountManagerName,
    required this.accountManagerPhone,
    required this.accountManagerEmail,
  });

  factory MySchedulePropertyDetail.fromJson(Map<String, dynamic> json) {
    return MySchedulePropertyDetail(
      taskId: '${json['task_id'] ?? ''}',
      assignmentId: '${json['assignment_id'] ?? ''}',
      propertyId: '${json['property_id'] ?? ''}',
      fieldAgentId: '${json['field_agent_id'] ?? ''}',
      assignedBy: '${json['assigned_by'] ?? ''}',
      visitType: '${json['visit_type'] ?? ''}',
      scheduledDate: '${json['scheduled_date'] ?? ''}',
      startTime: '${json['start_time'] ?? ''}',
      endTime: '${json['end_time'] ?? ''}',
      priority: '${json['priority'] ?? ''}',
      isRecurring: '${json['is_recurring'] ?? ''}',
      parentTaskId: '${json['parent_task_id'] ?? ''}',
      status: '${json['status'] ?? ''}',
      assignmentTimestamp: '${json['assignment_timestamp'] ?? ''}',
      startedAt: json['started_at']?.toString(),
      completedAt: json['completed_at']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: '${json['created_at'] ?? ''}',
      updatedAt: '${json['updated_at'] ?? ''}',
      propertyName: '${json['property_name'] ?? ''}',
      address: '${json['address'] ?? ''}',
      city: '${json['city'] ?? ''}',
      propertyLat: '${json['property_lat'] ?? ''}',
      propertyLng: '${json['property_lng'] ?? ''}',
      accountManagerName: '${json['account_manager_name'] ?? ''}',
      accountManagerPhone: '${json['account_manager_phone'] ?? ''}',
      accountManagerEmail: '${json['account_manager_email'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'assignment_id': assignmentId,
      'property_id': propertyId,
      'field_agent_id': fieldAgentId,
      'assigned_by': assignedBy,
      'visit_type': visitType,
      'scheduled_date': scheduledDate,
      'start_time': startTime,
      'end_time': endTime,
      'priority': priority,
      'is_recurring': isRecurring,
      'parent_task_id': parentTaskId,
      'status': status,
      'assignment_timestamp': assignmentTimestamp,
      'started_at': startedAt,
      'completed_at': completedAt,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'property_name': propertyName,
      'address': address,
      'city': city,
      'property_lat': propertyLat,
      'property_lng': propertyLng,
      'account_manager_name': accountManagerName,
      'account_manager_phone': accountManagerPhone,
      'account_manager_email': accountManagerEmail,
    };
  }
}

/// UI helpers preserved for existing Property Details / Submit Report screens.
extension MySchedulePropertyDetailUi on MySchedulePropertyDetail {
  String get locationLine {
    final parts = [address.trim(), city.trim()]
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  bool get hasMapCoordinates {
    final lat = propertyLat.trim();
    final lng = propertyLng.trim();
    if (lat.isEmpty || lng.isEmpty) return false;
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
      'https://www.google.com/maps/search/?api=1&query=${propertyLat.trim()},${propertyLng.trim()}',
    );
  }

  Uri? get callUri {
    final phone = accountManagerPhone.trim();
    if (phone.isEmpty) return null;
    return Uri(scheme: 'tel', path: phone);
  }

  Uri? get emailUri {
    final email = accountManagerEmail.trim();
    if (email.isEmpty) return null;
    return Uri(scheme: 'mailto', path: email);
  }

  List<String> get imageUrls => const [];

  List<({String label, String value})> get scheduleInfoEntries {
    final entries = <({String label, String? value})>[
      (label: 'Visit Type', value: visitType),
      (label: 'Scheduled Date', value: scheduledDate),
      (label: 'Priority', value: priority),
      (label: 'Status', value: status),
    ];

    return entries
        .where((entry) => entry.value?.trim().isNotEmpty == true)
        .map((entry) => (label: entry.label, value: entry.value!.trim()))
        .toList();
  }
}
