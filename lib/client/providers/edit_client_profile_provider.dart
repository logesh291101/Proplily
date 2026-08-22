import 'package:flutter/foundation.dart';
import 'package:proplilly/client/services/edit_client_profile_service.dart';

class EditClientProfileProvider extends ChangeNotifier {
  EditClientProfileProvider({EditClientProfileService? editClientProfileService})
      : _editClientProfileService =
            editClientProfileService ?? EditClientProfileService();

  final EditClientProfileService _editClientProfileService;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<EditClientProfileResult> updateProfile({
    String? name,
    String? phone,
    String? profileImagePath,
  }) async {
    if (_isLoading) {
      return const EditClientProfileFailure(message: null);
    }

    _isLoading = true;
    notifyListeners();

    try {
      return await _editClientProfileService.updateProfile(
        name: name?.trim(),
        phone: phone?.trim(),
        profileImagePath: profileImagePath?.trim(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
