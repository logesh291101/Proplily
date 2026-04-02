import 'package:flutter/foundation.dart';
import '../models/maintenance_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  
  List<User> _users = [];
  List<Vendor> _vendors = [];
  bool _isLoading = false;

  List<User> get users => _users;
  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers({String? search, String? status}) async {
    _isLoading = true;
    notifyListeners();
    _users = await _adminService.getUsers(search: search, status: status);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchVendors() async {
    _isLoading = true;
    notifyListeners();
    _vendors = await _adminService.getVendors();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleUserStatus(String id) async {
    final success = await _adminService.toggleUserStatus(id);
    if (success) {
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) {
        // Toggle property in local list logic here if needed
      }
      await fetchUsers();
    }
    return success;
  }

  Future<bool> approveProperty(String id) async {
    return await _adminService.verifyProperty(id, 'approved');
  }

  Future<bool> rejectProperty(String id) async {
    return await _adminService.verifyProperty(id, 'rejected');
  }

  Future<bool> assignCoordinator(String propertyId, String coordinatorId) async {
    return await _adminService.assignCoordinator(propertyId, coordinatorId);
  }
}
