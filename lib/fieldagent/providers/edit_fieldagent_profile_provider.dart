import 'package:flutter/foundation.dart';
import 'package:proplilly/fieldagent/edit_fieldagent_profile_service.dart';

class EditFieldAgentProfileProvider extends ChangeNotifier {
  EditFieldAgentProfileProvider({
    EditFieldAgentProfileService? editFieldAgentProfileService,
  }) : _editFieldAgentProfileService =
            editFieldAgentProfileService ?? EditFieldAgentProfileService();

  final EditFieldAgentProfileService _editFieldAgentProfileService;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<EditFieldAgentProfileResult> updateProfile({
    String? name,
    String? phone,
    String? profileImagePath,
  }) async {
    if (_isLoading) {
      return const EditFieldAgentProfileFailure(message: null);
    }

    _isLoading = true;
    notifyListeners();

    try {
      return await _editFieldAgentProfileService.updateProfile(
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
