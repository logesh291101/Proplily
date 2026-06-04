import 'package:flutter/foundation.dart';
import 'package:proplilly/models/referalcode_model.dart';
import 'package:proplilly/services/client_referral_service.dart';

class ClientReferralProvider extends ChangeNotifier {
  ClientReferralProvider({ClientReferralService? clientReferralService})
      : _clientReferralService =
            clientReferralService ?? ClientReferralService();

  final ClientReferralService _clientReferralService;

  bool _isLoadingCode = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  ReferalcodeModel? _referralModel;

  bool get isLoadingCode => _isLoadingCode;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  ReferalcodeModel? get referralModel => _referralModel;

  String? get referralCode {
    final code = _referralModel?.data?.ownReferralCode.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  bool get hasReferralCode => referralCode != null;

  Future<void> loadReferralCode() async {
    if (_isLoadingCode) return;

    _isLoadingCode = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _clientReferralService.fetchReferralCode();

    _isLoadingCode = false;

    switch (result) {
      case ClientReferralCodeFetchSuccess(:final model):
        _referralModel = model;
        _errorMessage = null;
      case ClientReferralCodeFetchFailure(:final message):
        _referralModel = null;
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<ClientReferralSubmitResult> submitReferral({
    required String fullName,
    required String email,
    required String countryDialCode,
    required String phoneNumber,
  }) async {
    if (_isSubmitting) {
      return const ClientReferralSubmitFailure(message: null);
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _clientReferralService.submitReferral(
      fullName: fullName.trim(),
      email: email.trim(),
      countryDialCode: countryDialCode.trim(),
      phoneNumber: phoneNumber.trim(),
    );

    _isSubmitting = false;
    notifyListeners();

    return result;
  }

  Future<void> refresh() => loadReferralCode();
}
