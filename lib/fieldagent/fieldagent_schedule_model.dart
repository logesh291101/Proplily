/// API response for `GET {live_url}/coordinator_api/tasks`.
class FieldAgentScheduleModel {
  FieldAgentScheduleModel({
    this.status,
    this.message,
    List<FieldAgentSchedule>? schedules,
    this.errors,
  }) : schedules = schedules ?? const [];

  final bool? status;
  final String? message;
  final List<FieldAgentSchedule> schedules;
  final dynamic errors;

  factory FieldAgentScheduleModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentScheduleModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      schedules: _parseSchedules(json['data']),
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': schedules.map((e) => e.toJson()).toList(),
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

  static List<FieldAgentSchedule> _parseSchedules(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => FieldAgentSchedule.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in ['scheduled_tasks', 'tasks', 'items', 'list']) {
        if (map[key] != null) {
          return _parseSchedules(map[key]);
        }
      }
    }

    return [];
  }
}

/// Single schedule entry from [FieldAgentScheduleModel.schedules].
class FieldAgentSchedule {
  FieldAgentSchedule({
    this.taskId,
    this.propertyName,
    this.visitType,
    this.scheduledDate,
    this.startTime,
    this.endTime,
    this.city,
    this.priority,
    this.status,
  });

  final String? taskId;
  final String? propertyName;
  final String? visitType;
  final String? scheduledDate;
  final String? startTime;
  final String? endTime;
  final String? city;
  final String? priority;
  final String? status;

  factory FieldAgentSchedule.fromJson(Map<String, dynamic> json) {
    return FieldAgentSchedule(
      taskId: _stringOrNull(json['task_id']),
      propertyName: _stringOrNull(json['property_name']),
      visitType: _stringOrNull(json['visit_type']),
      scheduledDate: _stringOrNull(json['scheduled_date']),
      startTime: _stringOrNull(json['start_time']),
      endTime: _stringOrNull(json['end_time']),
      city: _stringOrNull(json['city']),
      priority: _stringOrNull(json['priority']),
      status: _stringOrNull(json['status']),
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
      'property_name': propertyName,
      'visit_type': visitType,
      'scheduled_date': scheduledDate,
      'start_time': startTime,
      'end_time': endTime,
      'city': city,
      'priority': priority,
      'status': status,
    };
  }

  String get normalizedStatus => status?.trim().toLowerCase() ?? '';

  DateTime? get parsedScheduledDate {
    final raw = scheduledDate?.trim();
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  bool get canSubmitReport {
    final scheduled = parsedScheduledDate;
    if (scheduled == null) return false;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final scheduledDateOnly =
        DateTime(scheduled.year, scheduled.month, scheduled.day);

    return !scheduledDateOnly.isAfter(todayDate);
  }

  /// Accept / Reject / Reschedule are enabled from 3 days before through
  /// 3 days after the scheduled visit date (inclusive).
  bool get actionButtonsEnabled {
    final scheduled = parsedScheduledDate;
    if (scheduled == null) return false;

    final scheduledDateOnly =
        DateTime(scheduled.year, scheduled.month, scheduled.day);
    final windowStart = scheduledDateOnly.subtract(const Duration(days: 3));
    final windowEnd = scheduledDateOnly.add(const Duration(days: 3));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return !today.isBefore(windowStart) && !today.isAfter(windowEnd);
  }

  static int compareByScheduledDate(
    FieldAgentSchedule a,
    FieldAgentSchedule b,
  ) {
    final aDate = a.parsedScheduledDate;
    final bDate = b.parsedScheduledDate;

    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;

    return aDate.compareTo(bDate);
  }
}
