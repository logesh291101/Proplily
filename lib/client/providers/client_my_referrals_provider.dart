import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_referral_list_model.dart';
import 'package:proplilly/client/services/client_referral_list_service.dart';

class ClientMyReferralsProvider extends ChangeNotifier {
  ClientMyReferralsProvider({ClientReferralListService? service})
      : _service = service ?? ClientReferralListService();

  final ClientReferralListService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClientReferral> _referrals = <ClientReferral>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClientReferral> get referrals =>
      List<ClientReferral>.unmodifiable(_referrals);
  bool get hasData => _referrals.isNotEmpty && _errorMessage == null;

  Future<void> loadReferrals() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _referrals = <ClientReferral>[];
    notifyListeners();

    final result = await _service.fetchReferrals();

    _isLoading = false;

    switch (result) {
      case ClientReferralListFetchSuccess(:final model):
        _referrals = List<ClientReferral>.from(model.data.referrals);
        _errorMessage = null;
      case ClientReferralListFetchFailure(:final message):
        _referrals = <ClientReferral>[];
        _errorMessage = message.trim().isNotEmpty ? message.trim() : null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadReferrals();
}
