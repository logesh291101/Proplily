import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';
import '../models/property_model.dart';
import '../models/maintenance_model.dart';
import '../utils/preferences.dart';
import 'base_api_service.dart';

class AdminService extends BaseApiService {
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}admin_api/dashboard');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getTasks() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}admin_api/tasks');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> getUsers({String? search, String? status}) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      String endpoint = 'admin_api/users';
      if (search != null || status != null) {
        endpoint += '?';
        if (search != null) endpoint += 'search=$search&';
        if (status != null) endpoint += 'status=$status';
      }
      final response = await get('$baseUrl$endpoint');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((u) => User.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> rejectProperty(String id) async {
    return await verifyProperty(id, 'rejected');
  }

  Future<bool> toggleUserStatus(String id) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/users/toggle-status/$id', {});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Vendor>> getVendors() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}admin_api/vendors');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List).map((v) => Vendor.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> storeVendor({
    required String name,
    required String email,
    required String phone,
    required String serviceType,
    required String contactInfo,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/vendors/store', {
        'name': name,
        'email': email,
        'phone': phone,
        'service_type': serviceType,
        'contact_info': contactInfo,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePropertyAdmin({
    required String id,
    required String propertyName,
    required String address,
    required String city,
    required String monitoringStatus,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/properties/update/$id', {
        'property_name': propertyName,
        'address': address,
        'city': city,
        'monitoring_status': monitoringStatus,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> scheduleInspection({
    required String propertyId,
    required String inspectionDate,
    required String reportSummary,
    required String status,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/inspections/store', {
        'property_id': propertyId,
        'inspection_date': inspectionDate,
        'report_summary': reportSummary,
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyProperty(String id, String status) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/properties/verify/$id', {
        'status': status,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignCoordinator(String id, String coordinatorId) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/properties/assign/$id', {'coordinator_id': coordinatorId});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMaintenanceAdmin({
    required String id,
    required String vendorId,
    required String status,
    required double cost,
    File? resolutionImage,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      if (resolutionImage != null) {
        final response = await multipartPost(
          url: '${baseUrl}admin_api/maintenance/update/$id',
          fields: {
            'vendor_id': vendorId,
            'status': status,
            'cost': cost.toString(),
          },
          files: [resolutionImage],
          fieldName: 'resolution_image',
        );
        return response.statusCode == 200;
      } else {
        final response = await post('${baseUrl}admin_api/maintenance/update/$id', {
          'vendor_id': vendorId,
          'status': status,
          'cost': cost.toString(),
        });
        return response.statusCode == 200;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEmergencyAdmin({
    required String id,
    required String status,
    required String adminNotes,
    String? coordinatorId,
  }) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}admin_api/emergency/update/$id', {
        'status': status,
        'admin_notes': adminNotes,
        if (coordinatorId != null) 'coordinator_id': coordinatorId,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> closeSupportTicket(String id, File? resolutionImage) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      if (resolutionImage != null) {
        final response = await multipartPost(
          url: '${baseUrl}admin_api/support/close/$id',
          fields: {},
          files: [resolutionImage],
          fieldName: 'resolution_image',
        );
        return response.statusCode == 200;
      } else {
        final response = await post('${baseUrl}admin_api/support/close/$id', {});
        return response.statusCode == 200;
      }
    } catch (e) {
      return false;
    }
  }
}
