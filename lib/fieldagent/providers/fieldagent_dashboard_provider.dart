import 'package:flutter/foundation.dart';
import 'package:proplilly/fieldagent/fieldagent_ads_model.dart';
import 'package:proplilly/fieldagent/fieldagent_ads_service.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_model.dart';
import 'package:proplilly/fieldagent/fieldagent_my_schedules_service.dart';
import 'package:proplilly/fieldagent/models/fieldagent_dashboard_model.dart';
import 'package:proplilly/fieldagent/services/fieldagent_dashboard_service.dart';

class FieldAgentDashboardProvider extends ChangeNotifier {
  FieldAgentDashboardProvider({
    FieldAgentDashboardService? dashboardService,
    FieldAgentMySchedulesService? assignedPropertiesService,
    FieldAgentAdsService? adsService,
  })  : _dashboardService =
            dashboardService ?? FieldAgentDashboardService(),
        _assignedPropertiesService =
            assignedPropertiesService ?? FieldAgentMySchedulesService(),
        _adsService = adsService ?? FieldAgentAdsService();

  final FieldAgentDashboardService _dashboardService;
  final FieldAgentMySchedulesService _assignedPropertiesService;
  final FieldAgentAdsService _adsService;

  bool _isLoading = false;
  String? _errorMessage;
  FieldAgentDashboardModel? _dashboardModel;
  FieldAgentMySchedulesModel? _assignedPropertiesModel;
  FieldAgentAdsModel? _adsModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FieldAgentDashboardModel? get dashboardModel => _dashboardModel;
  FieldAgentMySchedulesModel? get assignedPropertiesModel =>
      _assignedPropertiesModel;
  FieldAgentAdsModel? get adsModel => _adsModel;
  DashboardData? get dashboardData => _dashboardModel?.data;

  bool get hasData => _dashboardModel != null && _errorMessage == null;

  int get scheduledTasksCount =>
      _dashboardModel?.data?.scheduledTasks.length ?? 0;

  int get assignedPropertiesCount =>
      _assignedPropertiesModel?.data?.length ?? 0;

  List<PropertyData> get assignedProperties =>
      _assignedPropertiesModel?.data ?? const [];

  List<FieldAgentAdData> get ads => _adsModel?.data ?? const [];

  bool get hasAds => ads.isNotEmpty;

  String get agentName => dashboardData?.fieldAgentName?.trim() ?? '';

  String get role => dashboardData?.role?.trim() ?? '';

  int? get pendingTasksCount => dashboardData?.summary?.pendingTasks;

  Future<void> loadDashboard() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _dashboardService.fetchDashboard(),
      _assignedPropertiesService.fetchProperties(),
      _adsService.fetchAds(),
    ]);

    final dashboardResult = results[0] as FieldAgentDashboardFetchResult;
    final propertiesResult = results[1] as FieldAgentMySchedulesFetchResult;
    final adsResult = results[2] as FieldAgentAdsFetchResult;

    _isLoading = false;

    switch (dashboardResult) {
      case FieldAgentDashboardFetchSuccess(:final model):
        _dashboardModel = model;
        _errorMessage = null;
      case FieldAgentDashboardFetchFailure(:final message):
        _dashboardModel = null;
        _errorMessage = message;
    }

    switch (propertiesResult) {
      case FieldAgentMySchedulesFetchSuccess(:final model):
        _assignedPropertiesModel = model;
      case FieldAgentMySchedulesFetchFailure():
        _assignedPropertiesModel = null;
    }

    switch (adsResult) {
      case FieldAgentAdsFetchSuccess(:final model):
        _adsModel = model;
      case FieldAgentAdsFetchFailure():
        _adsModel = null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadDashboard();
}
