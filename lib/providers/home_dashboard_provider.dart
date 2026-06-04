import 'package:flutter/foundation.dart';
import 'package:proplilly/models/Model/clientDashboard_model.dart';
import 'package:proplilly/models/home_dashboard.dart';
import 'package:proplilly/models/home_dashboard_mapper.dart';
import 'package:proplilly/services/home_service.dart';

/// Provider state for the home dashboard (API-backed).
class HomeDashboardProvider extends ChangeNotifier {
  HomeDashboardProvider({HomeService? homeService})
      : _homeService = homeService ?? HomeService();

  final HomeService _homeService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientDashboardModel? _dashboardData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientDashboardModel? get dashboardData => _dashboardData;

  /// UI-friendly view mapped from [dashboardData].
  HomeDashboard? get homeDashboard =>
      _dashboardData == null ? null : HomeDashboardMapper.toHomeDashboard(_dashboardData!);

  bool get hasData => _dashboardData != null;

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _homeService.fetchDashboard();

    _isLoading = false;

    switch (result) {
      case HomeDashboardFetchSuccess(:final model):
        _dashboardData = model;
        _errorMessage = null;
      case HomeDashboardFetchFailure(:final message):
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadDashboard();
}
