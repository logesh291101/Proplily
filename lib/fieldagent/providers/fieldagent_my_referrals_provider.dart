import 'package:flutter/foundation.dart';
import 'package:proplilly/fieldagent/fieldagent_referral_list_model.dart';
import 'package:proplilly/fieldagent/fieldagent_referral_list_service.dart';

class FieldAgentMyReferralsProvider extends ChangeNotifier {
  FieldAgentMyReferralsProvider({FieldAgentReferralListService? service})
      : _service = service ?? FieldAgentReferralListService();

  final FieldAgentReferralListService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<FieldAgentReferral> _referrals = <FieldAgentReferral>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FieldAgentReferral> get referrals =>
      List<FieldAgentReferral>.unmodifiable(_referrals);
  bool get hasData => _referrals.isNotEmpty && _errorMessage == null;

  Future<void> loadReferrals() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _referrals = <FieldAgentReferral>[];
    notifyListeners();

    final result = await _service.fetchReferrals();

    _isLoading = false;

    switch (result) {
      case FieldAgentReferralListFetchSuccess(:final model):
        _referrals = List<FieldAgentReferral>.from(model.data.referrals);
        _errorMessage = null;
      case FieldAgentReferralListFetchFailure(:final message):
        _referrals = <FieldAgentReferral>[];
        _errorMessage = message.trim().isNotEmpty ? message.trim() : null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadReferrals();
}
