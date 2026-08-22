// import 'package:proplilly/client/models/client_report_model.dart';
//
// /// API response for `GET {live_url}/user/visit-reports/{report_id}`.
// class ClientReportDetailModel {
//   final bool? status;
//   final String? message;
//   final ClientReportData? data;
//   final dynamic errors;
//
//   ClientReportDetailModel({
//     this.status,
//     this.message,
//     this.data,
//     this.errors,
//   });
//
//   factory ClientReportDetailModel.fromJson(Map<String, dynamic> json) {
//     return ClientReportDetailModel(
//       status: json['status'],
//       message: json['message'],
//       data: json['data'] != null
//           ? ClientReportData.fromJson(
//               Map<String, dynamic>.from(json['data'] as Map),
//             )
//           : null,
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data?.toJson(),
//       'errors': errors,
//     };
//   }
// }

import 'package:proplilly/client/models/client_report_model.dart';

/// API response for
/// `GET {live_url}/user/visit-reports/{report_id}`.
class ClientReportDetailModel {
  final bool status;
  final String message;
  final ClientReportData? data;
  final dynamic errors;

  ClientReportDetailModel({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory ClientReportDetailModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientReportDetailModel(
        status: false,
        message: '',
        data: null,
        errors: null,
      );
    }

    return ClientReportDetailModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
      data: _parseData(json['data']),
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

  static ClientReportData? _parseData(dynamic raw) {
    if (raw == null) return null;

    if (raw is Map<String, dynamic>) {
      return ClientReportData.fromJson(raw);
    }

    if (raw is Map) {
      return ClientReportData.fromJson(
        Map<String, dynamic>.from(raw),
      );
    }

    return null;
  }

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

  bool get isSuccess => status;
}