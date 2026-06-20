import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_profile_mapper.dart';
import 'package:proplilly/client/models/client_profile_model.dart';
import 'package:proplilly/client/models/client_user_profile.dart';
import 'package:proplilly/client/services/client_profile_service.dart';

class ClientProfileProvider extends ChangeNotifier {
  ClientProfileProvider({ClientProfileService? clientProfileService})
      : _clientProfileService = clientProfileService ?? ClientProfileService();

  final ClientProfileService _clientProfileService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientProfileModel? _profileData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientProfileModel? get profileData => _profileData;

  UserProfile? get displayProfile =>
      _profileData == null ? null : ClientProfileMapper.toUserProfile(_profileData!);

  bool get hasData => displayProfile != null && _errorMessage == null;

  bool get isDeletionScheduled =>
      _profileData?.data?.isDeletionScheduled ?? false;

  Future<void> loadProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _clientProfileService.fetchProfile();

    _isLoading = false;

    switch (result) {
      case ClientProfileFetchSuccess(:final model):
        _profileData = model;
        _errorMessage = null;
      case ClientProfileFetchFailure(:final message):
        _profileData = null;
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadProfile();
}
