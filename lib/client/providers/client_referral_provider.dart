import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_referral_code_model.dart';
import 'package:proplilly/client/services/client_referral_service.dart';

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
    required String name,
    required String email,
    required String countryCode,
    required String phoneNumber,
  }) async {
    if (_isSubmitting) {
      return const ClientReferralSubmitFailure(message: null);
    }

    _isSubmitting = true;
    notifyListeners();

    final nationalPhone =
        phoneNumber.replaceAll(RegExp(r'\D'), '').trim();

    final result = await _clientReferralService.submitReferral(
      name: name.trim(),
      email: email.trim(),
      countryCode: countryCode.trim(),
      phone: nationalPhone,
    );

    _isSubmitting = false;
    notifyListeners();

    return result;
  }

  Future<void> refresh() => loadReferralCode();
}
