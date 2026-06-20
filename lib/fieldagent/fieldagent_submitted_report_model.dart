class FieldAgentSubmittedReportModel {
  final bool? status;
  final String? message;
  final List<FieldAgentSubmittedReportData>? data;
  final dynamic errors;

  FieldAgentSubmittedReportModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory FieldAgentSubmittedReportModel.fromJson(Map<String, dynamic> json) {
    return FieldAgentSubmittedReportModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
              .whereType<Map>()
              .map(
                (e) => FieldAgentSubmittedReportData.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
          : <FieldAgentSubmittedReportData>[],
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
}

class FieldAgentSubmittedReportData {
  final String? reportId;
  final String? taskId;
  final String? propertyId;
  final String? fieldAgentId;
  final String? submittedAt;
  final String? visitType;
  final String? visitStatus;
  final String? visitDate;
  final String? gpsLatitude;
  final String? gpsLongitude;
  final String? propertyImages;
  final String? videoFile;
  final String? publicNotes;
  final String? reviewStatus;
  final String? managerComments;
  final String? managerDecision;
  final String? managerReviewedBy;
  final String? managerReviewedAt;
  final String? adminFinalStatus;
  final String? adminOverrideNotes;
  final String? adminReviewedBy;
  final String? adminReviewedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? geoTag;
  final String? propertyName;

  FieldAgentSubmittedReportData({
    this.reportId,
    this.taskId,
    this.propertyId,
    this.fieldAgentId,
    this.submittedAt,
    this.visitType,
    this.visitStatus,
    this.visitDate,
    this.gpsLatitude,
    this.gpsLongitude,
    this.propertyImages,
    this.videoFile,
    this.publicNotes,
    this.reviewStatus,
    this.managerComments,
    this.managerDecision,
    this.managerReviewedBy,
    this.managerReviewedAt,
    this.adminFinalStatus,
    this.adminOverrideNotes,
    this.adminReviewedBy,
    this.adminReviewedAt,
    this.createdAt,
    this.updatedAt,
    this.geoTag,
    this.propertyName,
  });

  factory FieldAgentSubmittedReportData.fromJson(Map<String, dynamic> json) {
    return FieldAgentSubmittedReportData(
      reportId: json['report_id']?.toString(),
      taskId: json['task_id']?.toString(),
      propertyId: json['property_id']?.toString(),
      fieldAgentId: json['field_agent_id']?.toString(),
      submittedAt: json['submitted_at'],
      visitType: json['visit_type'],
      visitStatus: json['visit_status'],
      visitDate: json['visit_date'],
      gpsLatitude: json['gps_latitude']?.toString(),
      gpsLongitude: json['gps_longitude']?.toString(),
      propertyImages: json['property_images'],
      videoFile: json['video_file'],
      publicNotes: json['public_notes'],
      reviewStatus: json['review_status'],
      managerComments: json['manager_comments'],
      managerDecision: json['manager_decision'],
      managerReviewedBy: json['manager_reviewed_by']?.toString(),
      managerReviewedAt: json['manager_reviewed_at'],
      adminFinalStatus: json['admin_final_status'],
      adminOverrideNotes: json['admin_override_notes'],
      adminReviewedBy: json['admin_reviewed_by']?.toString(),
      adminReviewedAt: json['admin_reviewed_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      geoTag: json['geo_tag'],
      propertyName: json['property_name'],
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
