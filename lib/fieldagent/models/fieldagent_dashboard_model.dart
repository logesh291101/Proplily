class FieldAgentDashboardModel {
  final bool? status;
  final String? message;
  final DashboardData? data;
  final dynamic errors;

  FieldAgentDashboardModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory FieldAgentDashboardModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentDashboardModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: json['data'] != null
          ? DashboardData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
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

  bool get isSuccess => status == true;
}

class DashboardData {
  final List<ScheduledTask> scheduledTasks;
  final Summary? summary;
  final String? fieldAgentName;
  final String? userType;

  DashboardData({
    List<ScheduledTask>? scheduledTasks,
    this.summary,
    this.fieldAgentName,
    this.userType,
  }) : scheduledTasks = scheduledTasks ?? const [];

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final profileMap = _asMap(json['profile']) ??
        _asMap(json['field_agent']) ??
        _asMap(json['user']);

    return DashboardData(
      scheduledTasks: _parseScheduledTasks(json['scheduled_tasks']),
      summary: json['summary'] != null
          ? Summary.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map),
            )
          : null,
      fieldAgentName: _firstNonEmptyString([
        json['field_agent_name'],
        json['agent_name'],
        json['name'],
        profileMap?['field_agent_name'],
        profileMap?['agent_name'],
        profileMap?['name'],
      ]),
      userType: _firstNonEmptyString([
        json['user_type'],
        json['role'],
        profileMap?['user_type'],
        profileMap?['role'],
      ]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduled_tasks': scheduledTasks.map((e) => e.toJson()).toList(),
      'summary': summary?.toJson(),
      'field_agent_name': fieldAgentName,
      'user_type': userType,
    };
  }

  int get scheduledTasksCount => scheduledTasks.length;

  int get assignedPropertiesCount => _countTasksWithStatus('assigned');

  int get confirmedPropertiesCount => _countTasksWithStatus('confirmed');

  int _countTasksWithStatus(String expectedStatus) {
    final target = expectedStatus.trim().toLowerCase();
    return scheduledTasks
        .where(
          (task) => task.status?.trim().toLowerCase() == target,
        )
        .length;
  }

  static List<ScheduledTask> _parseScheduledTasks(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => ScheduledTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  static String? _firstNonEmptyString(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final value = _stringOrNull(candidate);
      if (value != null) return value;
    }
    return null;
  }

  static String? _stringOrNull(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return raw.toString().trim().isEmpty ? null : raw.toString().trim();
  }
}

class ScheduledTask {
  final String? taskId;
  final String? assignmentId;
  final String? propertyId;
  final String? fieldAgentId;
  final String? assignedBy;
  final String? visitType;
  final String? scheduledDate;
  final String? startTime;
  final String? endTime;
  final String? priority;
  final String? isRecurring;
  final String? parentTaskId;
  final String? status;
  final String? assignmentTimestamp;
  final String? startedAt;
  final String? completedAt;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final String? propertyName;
  final String? address;
  final String? city;

  ScheduledTask({
    this.taskId,
    this.assignmentId,
    this.propertyId,
    this.fieldAgentId,
    this.assignedBy,
    this.visitType,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.priority,
    this.isRecurring,
    this.parentTaskId,
    this.status,
    this.assignmentTimestamp,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.propertyName,
    this.address,
    this.city,
  });

  factory ScheduledTask.fromJson(Map<String, dynamic> json) {
    return ScheduledTask(
      taskId: _stringOrNull(json['task_id']),
      assignmentId: _stringOrNull(json['assignment_id']),
      propertyId: _stringOrNull(json['property_id']),
      fieldAgentId: _stringOrNull(json['field_agent_id']),
      assignedBy: _stringOrNull(json['assigned_by']),
      visitType: _stringOrNull(json['visit_type']),
      scheduledDate: _stringOrNull(json['scheduled_date']),
      startTime: _stringOrNull(json['start_time']),
      endTime: _stringOrNull(json['end_time']),
      priority: _stringOrNull(json['priority']),
      isRecurring: _stringOrNull(json['is_recurring']),
      parentTaskId: _stringOrNull(json['parent_task_id']),
      status: _stringOrNull(json['status']),
      assignmentTimestamp: _stringOrNull(json['assignment_timestamp']),
      startedAt: _stringOrNull(json['started_at']),
      completedAt: _stringOrNull(json['completed_at']),
      notes: _stringOrNull(json['notes']),
      createdAt: _stringOrNull(json['created_at']),
      updatedAt: _stringOrNull(json['updated_at']),
      propertyName: _stringOrNull(json['property_name']),
      address: _stringOrNull(json['address']),
      city: _stringOrNull(json['city']),
    );
  }

  static String? _stringOrNull(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.isEmpty ? null : raw;
    return raw.toString();
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
    };
  }
}

class Summary {
  final int? pendingTasks;

  Summary({
    this.pendingTasks,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      pendingTasks: _parseInt(json['pending_tasks']),
    );
  }

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw.trim());
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'pending_tasks': pendingTasks,
    };
  }
}
