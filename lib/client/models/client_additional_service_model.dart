// class ClientAdditionalServiceModel {
//   final bool status;
//   final String message;
//   final List<ClientAdditionalService> data;
//   final dynamic errors;
//
//   ClientAdditionalServiceModel({
//     required this.status,
//     required this.message,
//     required this.data,
//     this.errors,
//   });
//
//   factory ClientAdditionalServiceModel.fromJson(Map<String, dynamic> json) {
//     return ClientAdditionalServiceModel(
//       status: json['status'] ?? false,
//       message: json['message']?.toString() ?? '',
//       data: (json['data'] as List<dynamic>? ?? [])
//           .whereType<Map>()
//           .map(
//             (e) => ClientAdditionalService.fromJson(
//               Map<String, dynamic>.from(e),
//             ),
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
//   static List<ClientAdditionalService> parseServiceList(dynamic raw) {
//     if (raw == null) return [];
//
//     if (raw is List) {
//       return raw
//           .whereType<Map>()
//           .map(
//             (e) => ClientAdditionalService.fromJson(
//               Map<String, dynamic>.from(e),
//             ),
//           )
//           .toList();
//     }
//
//     if (raw is Map) {
//       return [
//         ClientAdditionalService.fromJson(Map<String, dynamic>.from(raw)),
//       ];
//     }
//
//     return [];
//   }
// }
//
// class ClientAdditionalService {
//   final String id;
//   final String clientId;
//   final String serviceType;
//   final String? comments;
//   final String status;
//   final String managerId;
//   final String? adminId;
//   final String createdAt;
//   final String updatedAt;
//   final String clientName;
//   final String managerName;
//   final String? adminName;
//
//   ClientAdditionalService({
//     required this.id,
//     required this.clientId,
//     required this.serviceType,
//     this.comments,
//     required this.status,
//     required this.managerId,
//     this.adminId,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.clientName,
//     required this.managerName,
//     this.adminName,
//   });
//
//   factory ClientAdditionalService.fromJson(Map<String, dynamic> json) {
//     return ClientAdditionalService(
//       id: json['id']?.toString() ?? '',
//       clientId: json['client_id']?.toString() ?? '',
//       serviceType: json['service_type']?.toString() ?? '',
//       comments: json['comments']?.toString(),
//       status: json['status']?.toString() ?? '',
//       managerId: json['manager_id']?.toString() ?? '',
//       adminId: json['admin_id']?.toString(),
//       createdAt: json['created_at']?.toString() ?? '',
//       updatedAt: json['updated_at']?.toString() ?? '',
//       clientName: json['client_name']?.toString() ?? '',
//       managerName: json['manager_name']?.toString() ?? '',
//       adminName: json['admin_name']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'client_id': clientId,
//       'service_type': serviceType,
//       'comments': comments,
//       'status': status,
//       'manager_id': managerId,
//       'admin_id': adminId,
//       'created_at': createdAt,
//       'updated_at': updatedAt,
//       'client_name': clientName,
//       'manager_name': managerName,
//       'admin_name': adminName,
//     };
//   }
// }

class ClientAdditionalServiceModel {
  final bool status;
  final String message;
  final List<ClientAdditionalService> data;
  final dynamic errors;

  ClientAdditionalServiceModel({
    required this.status,
    required this.message,
    required this.data,
    this.errors,
  });

  factory ClientAdditionalServiceModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAdditionalServiceModel(
        status: false,
        message: '',
        data: [],
        errors: null,
      );
    }

    return ClientAdditionalServiceModel(
      status: json['status'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: parseServiceList(json['data']),
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

  static List<ClientAdditionalService> parseServiceList(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map(
            (e) => ClientAdditionalService.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();
    }

    if (raw is Map) {
      return [
        ClientAdditionalService.fromJson(
          Map<String, dynamic>.from(raw),
        ),
      ];
    }

    return [];
  }
}

class ClientAdditionalService {
  final String id;
  final String clientId;
  final String serviceType;
  final String? comments;
  final String status;
  final String managerId;
  final String? adminId;
  final String createdAt;
  final String updatedAt;
  final String clientName;
  final String managerName;
  final String? adminName;

  ClientAdditionalService({
    required this.id,
    required this.clientId,
    required this.serviceType,
    this.comments,
    required this.status,
    required this.managerId,
    this.adminId,
    required this.createdAt,
    required this.updatedAt,
    required this.clientName,
    required this.managerName,
    this.adminName,
  });

  factory ClientAdditionalService.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ClientAdditionalService(
        id: '',
        clientId: '',
        serviceType: '',
        comments: null,
        status: '',
        managerId: '',
        adminId: null,
        createdAt: '',
        updatedAt: '',
        clientName: '',
        managerName: '',
        adminName: null,
      );
    }

    return ClientAdditionalService(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      serviceType: json['service_type']?.toString() ?? '',
      comments: json['comments']?.toString(),
      status: json['status']?.toString() ?? '',
      managerId: json['manager_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      clientName: json['client_name']?.toString() ?? '',
      managerName: json['manager_name']?.toString() ?? '',
      adminName: json['admin_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'service_type': serviceType,
      'comments': comments,
      'status': status,
      'manager_id': managerId,
      'admin_id': adminId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'client_name': clientName,
      'manager_name': managerName,
      'admin_name': adminName,
    };
  }
}