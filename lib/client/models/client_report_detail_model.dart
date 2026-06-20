import 'package:proplilly/client/models/client_report_model.dart';

/// API response for `GET {live_url}/user/visit-reports/{report_id}`.
class ClientReportDetailModel {
  final bool? status;
  final String? message;
  final ClientReportData? data;
  final dynamic errors;

  ClientReportDetailModel({
    this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory ClientReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ClientReportDetailModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? ClientReportData.fromJson(
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
}
