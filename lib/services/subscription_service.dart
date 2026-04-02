import 'dart:convert';
import '../models/subscription_model.dart';
import '../utils/preferences.dart';
import 'base_api_service.dart';

class SubscriptionService extends BaseApiService {
  static final List<PlanDetails> _availablePlans = [
    PlanDetails(
      planKey: SubscriptionPlan.basic,
      title: 'Basic Plan',
      price: 19.99,
      duration: 'Month',
      features: ['2 Property Monitoring', 'Weekly Reports', 'Basic Maintenance'],
    ),
    PlanDetails(
      planKey: SubscriptionPlan.premium,
      title: 'Premium Plan',
      price: 49.99,
      duration: 'Month',
      features: ['Unlimited Properties', 'Daily Reports', 'Priority Maintenance', 'Emergency Support'],
    ),
  ];

  List<PlanDetails> get availablePlans => _availablePlans;

  static bool _hasActiveSub = false;
  bool get hasActiveSubscription => _hasActiveSub;

  Future<List<PlanDetails>> getPlans() async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}api_subscriptions/plans');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the API returns a list of plan objects
        return (data as List).map((p) => PlanDetails.fromJson(p)).toList();
      }
      return _availablePlans; // Fallback to current mock if API fails
    } catch (e) {
      return _availablePlans;
    }
  }

  Future<Map<String, dynamic>?> purchasePlan(String planId) async {
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api_subscriptions/purchase', {'plan_id': planId});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updatePlan(
    SubscriptionPlan planKey,
    String title,
    double price,
    String duration,
    List<String> features,
  ) async {
    try {
      final index = _availablePlans.indexWhere((p) => p.planKey == planKey);
      if (index != -1) {
        _availablePlans[index].title = title;
        _availablePlans[index].price = price;
        _availablePlans[index].duration = duration;
        _availablePlans[index].features = features;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Subscription?> processSubscriptionPayment({
    required SubscriptionPlan plan,
    required SubscriptionPeriod period,
    required double amount,
  }) async {
    // MOCK SUCCESS FOR NOW
    _hasActiveSub = true;
    return Subscription(
      id: 'mock_sub_id',
      userId: 'mock_user_id',
      propertyId: 'mock_property_id',
      plan: plan,
      period: period,
      amount: amount,
      status: SubscriptionStatus.active,
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );
    /*
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await post('${baseUrl}api_subscriptions/payment', {
        'plan': plan.toString().split('.').last,
        'period': period.toString().split('.').last,
        'amount': amount,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _hasActiveSub = true;
        return Subscription.fromJson(data['data'] ?? data);
      }
      return null;
    } catch (e) {
      return null;
    }
    */
  }

  Future<bool> hasActiveSubscriptionStatus() async {
    // MOCK STATUS AS ACTIVE FOR NOW
    _hasActiveSub = true;
    return true;
    /*
    try {
      final liveUrl = Prefs.getString('live_url') ?? 'https://api.proplilly.com/';
      final baseUrl = liveUrl.endsWith('/') ? liveUrl : '$liveUrl/';
      final response = await get('${baseUrl}user/subscription/status');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _hasActiveSub = data['has_active_subscription'] == true;
        return _hasActiveSub;
      }
      return _hasActiveSub;
    } catch (e) {
      return _hasActiveSub;
    }
    */
  }
}
