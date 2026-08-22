// class ClientPropertyStatusModel {
//   final bool status;
//   final String message;
//   final List<ClientPropertyStatus> data;
//   final dynamic errors;
//
//   ClientPropertyStatusModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientPropertyStatusModel.fromJson(Map<String, dynamic> json) {
//     return ClientPropertyStatusModel(
//       status: json['status'] ?? false,
//       message: json['message']?.toString() ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientPropertyStatus.fromJson(Map<String, dynamic>.from(e)),
//           )
//           .toList(),
//       errors: json['errors'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status,
//       'message': message,
//       'data': data.map((e) => e.toJson()).toList(),
//       'errors': errors,
//     };
//   }
//
//   static List<ClientPropertyStatus> parsePropertyStatusList(dynamic raw) {
//     if (raw == null) return [];
//
//     if (raw is List) {
//       return raw
//           .whereType<Map>()
//           .map(
//             (e) => ClientPropertyStatus.fromJson(Map<String, dynamic>.from(e)),
//           )
//           .toList();
//     }
//
//     if (raw is Map) {
//       return [
//         ClientPropertyStatus.fromJson(Map<String, dynamic>.from(raw)),
//       ];
//     }
//
//     return [];
//   }
// }
//
// class ClientPropertyStatus {
//   final String propertyId;
//   final String propertyName;
//   final String monitoringStatus;
//   final String? coordinatorId;
//   final String? coordinatorName;
//   final String accountManagerName;
//   final String accountManagerPhone;
//   final String? lastVisit;
//   final String? latestReviewStatus;
//   final String? latestAdminStatus;
//
//   ClientPropertyStatus({
//     required this.propertyId,
//     required this.propertyName,
//     required this.monitoringStatus,
//     this.coordinatorId,
//     this.coordinatorName,
//     required this.accountManagerName,
//     required this.accountManagerPhone,
//     this.lastVisit,
//     this.latestReviewStatus,
//     this.latestAdminStatus,
//   });
//
//   factory ClientPropertyStatus.fromJson(Map<String, dynamic> json) {
//     return ClientPropertyStatus(
//       propertyId: json['property_id']?.toString() ?? '',
//       propertyName: json['property_name']?.toString() ?? '',
//       monitoringStatus: json['monitoring_status']?.toString() ?? '',
//       coordinatorId: json['coordinator_id']?.toString(),
//       coordinatorName: json['coordinator_name']?.toString(),
//       accountManagerName: json['account_manager_name']?.toString() ?? '',
//       accountManagerPhone: json['account_manager_phone']?.toString() ?? '',
//       lastVisit: json['last_visit']?.toString(),
//       latestReviewStatus: json['latest_review_status']?.toString(),
//       latestAdminStatus: json['latest_admin_status']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'property_id': propertyId,
//       'property_name': propertyName,
//       'monitoring_status': monitoringStatus,
//       'coordinator_id': coordinatorId,
//       'coordinator_name': coordinatorName,
//       'account_manager_name': accountManagerName,
//       'account_manager_phone': accountManagerPhone,
//       'last_visit': lastVisit,
//       'latest_review_status': latestReviewStatus,
//       'latest_admin_status': latestAdminStatus,
//     };
//   }
// }


class ClientPropertyStatusModel {
  final bool status;
  final String message;
  final List<ClientPropertyStatus> data;
  final dynamic errors;

  ClientPropertyStatusModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientPropertyStatusModel.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientPropertyStatusModel(
        status: false,
        message: '',
        data: const [],
        errors: null,
      );
    }

    return ClientPropertyStatusModel(
      status: _parseStatus(json['status']),
      message: json['message']?.toString() ?? '',
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

  static List<ClientPropertyStatus> parsePropertyStatusList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientPropertyStatus.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientPropertyStatus.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientPropertyStatus {
  final String propertyId;
  final String propertyName;
  final String monitoringStatus;
  final String? coordinatorId;
  final String? coordinatorName;
  final String accountManagerName;
  final String accountManagerPhone;
  final String? lastVisit;
  final String? latestReviewStatus;
  final String? latestAdminStatus;

  ClientPropertyStatus({
    required this.propertyId,
    required this.propertyName,
    required this.monitoringStatus,
    this.coordinatorId,
    this.coordinatorName,
    required this.accountManagerName,
    required this.accountManagerPhone,
    this.lastVisit,
    this.latestReviewStatus,
    this.latestAdminStatus,
  });

  factory ClientPropertyStatus.fromJson(
      Map<String, dynamic>? json,
      ) {
    if (json == null) {
      return ClientPropertyStatus(
        propertyId: '',
        propertyName: '',
        monitoringStatus: '',
        coordinatorId: null,
        coordinatorName: null,
        accountManagerName: '',
        accountManagerPhone: '',
        lastVisit: null,
        latestReviewStatus: null,
        latestAdminStatus: null,
      );
    }

    return ClientPropertyStatus(
      propertyId: json['property_id']?.toString() ?? '',
      propertyName: json['property_name']?.toString() ?? '',
      monitoringStatus: json['monitoring_status']?.toString() ?? '',
      coordinatorId: json['coordinator_id']?.toString(),
      coordinatorName: json['coordinator_name']?.toString(),
      accountManagerName:
      json['account_manager_name']?.toString() ?? '',
      accountManagerPhone:
      json['account_manager_phone']?.toString() ?? '',
      lastVisit: json['last_visit']?.toString(),
      latestReviewStatus:
      json['latest_review_status']?.toString(),
      latestAdminStatus:
      json['latest_admin_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'property_name': propertyName,
      'monitoring_status': monitoringStatus,
      'coordinator_id': coordinatorId,
      'coordinator_name': coordinatorName,
      'account_manager_name': accountManagerName,
      'account_manager_phone': accountManagerPhone,
      'last_visit': lastVisit,
      'latest_review_status': latestReviewStatus,
      'latest_admin_status': latestAdminStatus,
    };
  }
}