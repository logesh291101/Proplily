/// API response for `GET {live_url}/coordinator_api/tasks/{task_id}/report`.
class FieldAgentViewReportModel {
  FieldAgentViewReportModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  final bool? status;
  final String? message;
  final FieldAgentViewReportData? data;
  final dynamic errors;

  factory FieldAgentViewReportModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentViewReportModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString(),
      data: _parseData(json['data']),
      errors: json['errors'],
    );
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

  static FieldAgentViewReportData? _parseData(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      return FieldAgentViewReportData.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }
    return null;
  }
}

class FieldAgentViewReportData {
  FieldAgentViewReportData({
    this.taskId,
    this.reportComment,
    this.submittedAt,
    this.propertyName,
    this.address,
    this.city,
    this.visitType,
    this.scheduledDate,
    this.status,
    this.videoUrl,
    List<String>? propertyImages,
  }) : propertyImages = propertyImages ?? const [];

  final String? taskId;
  final String? reportComment;
  final String? submittedAt;
  final String? propertyName;
  final String? address;
  final String? city;
  final String? visitType;
  final String? scheduledDate;
  final String? status;
  final String? videoUrl;
  final List<String> propertyImages;

  factory FieldAgentViewReportData.fromJson(Map<String, dynamic> json) {
    return FieldAgentViewReportData(
      taskId: _stringOrNull(json['task_id']),
      reportComment: _stringOrNull(json['report_comment']),
      submittedAt: _stringOrNull(json['submitted_at'] ?? json['created_at']),
      propertyName: _stringOrNull(json['property_name']),
      address: _stringOrNull(json['address']),
      city: _stringOrNull(json['city']),
      visitType: _stringOrNull(json['visit_type']),
      scheduledDate: _stringOrNull(json['scheduled_date']),
      status: _stringOrNull(json['status']),
      videoUrl: _stringOrNull(json['video'] ?? json['video_url']),
      propertyImages: _parseImages(
        json['property_images'] ?? json['images'] ?? json['property_photos'],
      ),
    );
  }

  String get locationLine {
    final parts = [address?.trim(), city?.trim()]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  List<({String label, String value})> get detailEntries {
    final entries = <({String label, String? value})>[
      (label: 'Visit Type', value: visitType),
      (label: 'Scheduled Date', value: scheduledDate),
      (label: 'Status', value: status),
      (label: 'Submitted At', value: submittedAt),
      (label: 'Report Comment', value: reportComment),
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

  static List<String> _parseImages(dynamic raw) {
    if (raw == null) return [];

    final urls = <String>[];
    void addUrl(String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty && !urls.contains(trimmed)) {
        urls.add(trimmed);
      }
    }

    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          addUrl(_stringOrNull(item['url']) ?? _stringOrNull(item['image']));
        } else {
          addUrl(_stringOrNull(item));
        }
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      if (raw.contains(',')) {
        for (final part in raw.split(',')) {
          addUrl(part);
        }
      } else {
        addUrl(raw);
      }
    }

    return urls;
  }
}
