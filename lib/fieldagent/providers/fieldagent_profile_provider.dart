import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_user_profile.dart';
import 'package:proplilly/fieldagent/fieldagent_profile_mapper.dart';
import 'package:proplilly/fieldagent/fieldagent_profile_model.dart';
import 'package:proplilly/fieldagent/fieldagent_profile_service.dart';

class FieldAgentProfileProvider extends ChangeNotifier {
  FieldAgentProfileProvider({FieldAgentProfileService? profileService})
      : _profileService = profileService ?? FieldAgentProfileService();

  final FieldAgentProfileService _profileService;

  bool _isLoading = false;
  String? _errorMessage;
  FieldAgentProfileModel? _profileData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FieldAgentProfileModel? get profileData => _profileData;

  UserProfile? get displayProfile => _profileData == null
      ? null
      : FieldAgentProfileMapper.toUserProfile(_profileData!);

  bool get hasData => displayProfile != null && _errorMessage == null;

  bool get isDeletionScheduled {
    final data = _profileData?.data;
    if (data == null) return false;
    return FieldAgentProfileMapper.isDeletionScheduled(data);
  }

  Future<void> loadProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _profileService.fetchProfile();

    _isLoading = false;

    switch (result) {
      case FieldAgentProfileFetchSuccess(:final model):
        _profileData = model;
        _errorMessage = null;
      case FieldAgentProfileFetchFailure(:final message):
        _profileData = null;
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadProfile();
}
