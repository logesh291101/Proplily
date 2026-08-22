// class ClientReportModel {
//   final bool? status;
//   final String? message;
//   final List<ClientReportData>? data;
//   final dynamic errors;
//
//   ClientReportModel({
//     this.status,
//     this.message,
//     this.data,
//     this.errors,
//   });
//
//   factory ClientReportModel.fromJson(Map<String, dynamic> json) {
//     return ClientReportModel(
//       status: json['status'],
//       message: json['message'],
//       data: json['data'] != null
//           ? (json['data'] as List)
//               .whereType<Map>()
//               .map((e) => ClientReportData.fromJson(Map<String, dynamic>.from(e)))
//               .toList()
//           : <ClientReportData>[],
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data?.map((e) => e.toJson()).toList(),
//       'errors': errors,
//     };
//   }
// }
//
// class ClientReportData {
//   final String? reportId;
//   final String? taskId;
//   final String? propertyId;
//   final String? fieldAgentId;
//   final String? submittedAt;
//   final String? visitType;
//   final String? visitStatus;
//   final String? visitDate;
//   final String? gpsLatitude;
//   final String? gpsLongitude;
//   final String? propertyImages;
//   final String? videoFile;
//   final String? publicNotes;
//   final String? reviewStatus;
//   final String? managerComments;
//   final String? managerDecision;
//   final String? managerReviewedBy;
//   final String? managerReviewedAt;
//   final String? adminFinalStatus;
//   final String? adminOverrideNotes;
//   final String? adminReviewedBy;
//   final String? adminReviewedAt;
//   final String? createdAt;
//   final String? updatedAt;
//   final String? geoTag;
//   final String? propertyName;
//
//   ClientReportData({
//     this.reportId,
//     this.taskId,
//     this.propertyId,
//     this.fieldAgentId,
//     this.submittedAt,
//     this.visitType,
//     this.visitStatus,
//     this.visitDate,
//     this.gpsLatitude,
//     this.gpsLongitude,
//     this.propertyImages,
//     this.videoFile,
//     this.publicNotes,
//     this.reviewStatus,
//     this.managerComments,
//     this.managerDecision,
//     this.managerReviewedBy,
//     this.managerReviewedAt,
//     this.adminFinalStatus,
//     this.adminOverrideNotes,
//     this.adminReviewedBy,
//     this.adminReviewedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.geoTag,
//     this.propertyName,
//   });
//
//   factory ClientReportData.fromJson(Map<String, dynamic> json) {
//     return ClientReportData(
//       reportId: json['report_id']?.toString(),
//       taskId: json['task_id']?.toString(),
//       propertyId: json['property_id']?.toString(),
//       fieldAgentId: json['field_agent_id']?.toString(),
//       submittedAt: json['submitted_at'],
//       visitType: json['visit_type'],
//       visitStatus: json['visit_status'],
//       visitDate: json['visit_date'],
//       gpsLatitude: json['gps_latitude']?.toString(),
//       gpsLongitude: json['gps_longitude']?.toString(),
//       propertyImages: json['property_images'],
//       videoFile: json['video_file'],
//       publicNotes: json['public_notes'],
//       reviewStatus: json['review_status'],
//       managerComments: json['manager_comments'],
//       managerDecision: json['manager_decision'],
//       managerReviewedBy: json['manager_reviewed_by']?.toString(),
//       managerReviewedAt: json['manager_reviewed_at'],
//       adminFinalStatus: json['admin_final_status'],
//       adminOverrideNotes: json['admin_override_notes'],
//       adminReviewedBy: json['admin_reviewed_by']?.toString(),
//       adminReviewedAt: json['admin_reviewed_at'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       geoTag: json['geo_tag'],
//       propertyName: json['property_name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'report_id': reportId,
//       'task_id': taskId,
//       'property_id': propertyId,
//       'field_agent_id': fieldAgentId,
//       'submitted_at': submittedAt,
//       'visit_type': visitType,
//       'visit_status': visitStatus,
//       'visit_date': visitDate,
//       'gps_latitude': gpsLatitude,
//       'gps_longitude': gpsLongitude,
//       'property_images': propertyImages,
//       'video_file': videoFile,
//       'public_notes': publicNotes,
//       'review_status': reviewStatus,
//       'manager_comments': managerComments,
//       'manager_decision': managerDecision,
//       'manager_reviewed_by': managerReviewedBy,
//       'manager_reviewed_at': managerReviewedAt,
//       'admin_final_status': adminFinalStatus,
//       'admin_override_notes': adminOverrideNotes,
//       'admin_reviewed_by': adminReviewedBy,
//       'admin_reviewed_at': adminReviewedAt,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'geo_tag': geoTag,
//       'property_name': propertyName,
//     };
//   }
// }

class ClientReportModel {
  final bool status;
  final String message;
  final List<ClientReportData> data;
  final dynamic errors;

  ClientReportModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientReportModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientReportModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientReportModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: _parseReportList(json['data']),
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

  bool get isSuccess => status;

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

  static List<ClientReportData> _parseReportList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientReportData.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientReportData.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientReportData {
  final String reportId;
  final String taskId;
  final String propertyId;
  final String fieldAgentId;
  final String submittedAt;
  final String visitType;
  final String visitStatus;
  final String visitDate;
  final String gpsLatitude;
  final String gpsLongitude;
  final String propertyImages;
  final String videoFile;
  final String publicNotes;
  final String reviewStatus;
  final String managerComments;
  final String managerDecision;
  final String managerReviewedBy;
  final String managerReviewedAt;
  final String adminFinalStatus;
  final String adminOverrideNotes;
  final String adminReviewedBy;
  final String adminReviewedAt;
  final String createdAt;
  final String updatedAt;
  final String geoTag;
  final String propertyName;

  ClientReportData({
    required this.reportId,
    required this.taskId,
    required this.propertyId,
    required this.fieldAgentId,
    required this.submittedAt,
    required this.visitType,
    required this.visitStatus,
    required this.visitDate,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.propertyImages,
    required this.videoFile,
    required this.publicNotes,
    required this.reviewStatus,
    required this.managerComments,
    required this.managerDecision,
    required this.managerReviewedBy,
    required this.managerReviewedAt,
    required this.adminFinalStatus,
    required this.adminOverrideNotes,
    required this.adminReviewedBy,
    required this.adminReviewedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.geoTag,
    required this.propertyName,
  });

  factory ClientReportData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientReportData(
        reportId: '',
        taskId: '',
        propertyId: '',
        fieldAgentId: '',
        submittedAt: '',
        visitType: '',
        visitStatus: '',
        visitDate: '',
        gpsLatitude: '',
        gpsLongitude: '',
        propertyImages: '',
        videoFile: '',
        publicNotes: '',
        reviewStatus: '',
        managerComments: '',
        managerDecision: '',
        managerReviewedBy: '',
        managerReviewedAt: '',
        adminFinalStatus: '',
        adminOverrideNotes: '',
        adminReviewedBy: '',
        adminReviewedAt: '',
        createdAt: '',
        updatedAt: '',
        geoTag: '',
        propertyName: '',
      );
    }

    return ClientReportData(
      reportId: json['report_id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      propertyId: json['property_id']?.toString() ?? '',
      fieldAgentId: json['field_agent_id']?.toString() ?? '',
      submittedAt: json['submitted_at']?.toString() ?? '',
      visitType: json['visit_type']?.toString() ?? '',
      visitStatus: json['visit_status']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
      gpsLatitude: json['gps_latitude']?.toString() ?? '',
      gpsLongitude: json['gps_longitude']?.toString() ?? '',
      propertyImages: json['property_images']?.toString() ?? '',
      videoFile: json['video_file']?.toString() ?? '',
      publicNotes: json['public_notes']?.toString() ?? '',
      reviewStatus: json['review_status']?.toString() ?? '',
      managerComments: json['manager_comments']?.toString() ?? '',
      managerDecision: json['manager_decision']?.toString() ?? '',
      managerReviewedBy: json['manager_reviewed_by']?.toString() ?? '',
      managerReviewedAt: json['manager_reviewed_at']?.toString() ?? '',
      adminFinalStatus: json['admin_final_status']?.toString() ?? '',
      adminOverrideNotes: json['admin_override_notes']?.toString() ?? '',
      adminReviewedBy: json['admin_reviewed_by']?.toString() ?? '',
      adminReviewedAt: json['admin_reviewed_at']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      geoTag: json['geo_tag']?.toString() ?? '',
      propertyName: json['property_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'task_id': taskId,
      'property_id': propertyId,
      'field_agent_id': fieldAgentId,
      'submitted_at': submittedAt,
      'visit_type': visitType,
      'visit_status': visitStatus,
      'visit_date': visitDate,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'property_images': propertyImages,
      'video_file': videoFile,
      'public_notes': publicNotes,
      'review_status': reviewStatus,
      'manager_comments': managerComments,
      'manager_decision': managerDecision,
      'manager_reviewed_by': managerReviewedBy,
      'manager_reviewed_at': managerReviewedAt,
      'admin_final_status': adminFinalStatus,
      'admin_override_notes': adminOverrideNotes,
      'admin_reviewed_by': adminReviewedBy,
      'admin_reviewed_at': adminReviewedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'geo_tag': geoTag,
      'property_name': propertyName,
    };
  }
}
