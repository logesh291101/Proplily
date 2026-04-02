import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  
  List<PlanDetails> _plans = [];
  bool _isLoading = false;

  List<PlanDetails> get plans => _plans;
  List<PlanDetails> get availablePlans => _plans;
  bool get isLoading => _isLoading;

  bool _hasActiveSub = false;
  bool get hasActiveSubscription => _hasActiveSub;
  
  // Method alias for UI screens that call it as a function: hasActiveSubscription()
  bool hasActiveSubscriptionStatus() => _hasActiveSub;

  Future<void> fetchPlans() async {
    _isLoading = true;
    notifyListeners();
    _plans = await _subscriptionService.getPlans();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkSubscriptionStatus() async {
    // Corrected to call the async method in service
    _hasActiveSub = await _subscriptionService.hasActiveSubscriptionStatus();
    notifyListeners();
  }

  Future<bool> purchasePlan(String planId) async {
    final result = await _subscriptionService.purchasePlan(planId);
    if (result != null) {
      _hasActiveSub = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updatePlan(
    SubscriptionPlan planKey,
    String title,
    double price,
    String duration,
    List<String> features,
  ) async {
    final success = await _subscriptionService.updatePlan(planKey, title, price, duration, features);
    if (success) {
      await fetchPlans();
    }
    return success;
  }

  Future<bool> processSubscriptionPayment({
    required SubscriptionPlan plan,
    required SubscriptionPeriod period,
    required double amount,
  }) async {
    final result = await _subscriptionService.processSubscriptionPayment(
      plan: plan,
      period: period,
      amount: amount,
    );
    if (result != null) {
      _hasActiveSub = true;
      notifyListeners();
      return true;
    }
    return false;
  }
}
