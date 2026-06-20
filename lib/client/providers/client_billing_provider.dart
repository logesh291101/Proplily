import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_billing_model.dart';
import 'package:proplilly/client/services/client_billing_service.dart';

class BillingProvider extends ChangeNotifier {
  BillingProvider({BillingService? billingService})
      : _billingService = billingService ?? BillingService();

  final BillingService _billingService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientBillingModel? _billingModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientBillingModel? get billingModel => _billingModel;

  List<BillingHistory> get billingRecords => _billingModel?.data ?? [];

  bool get hasData => billingRecords.isNotEmpty && _errorMessage == null;

  Future<void> loadBilling() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _billingService.fetchBilling();

    _isLoading = false;

    switch (result) {
      case BillingFetchSuccess(:final model):
        _billingModel = model;
        if (model.data.isEmpty) {
          final msg = model.message.trim();
          _errorMessage =
              msg.isNotEmpty ? msg : 'No billing information available.';
          _billingModel = null;
        } else {
          _errorMessage = null;
        }
      case BillingFetchFailure(:final message):
        _billingModel = null;
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadBilling();
}
