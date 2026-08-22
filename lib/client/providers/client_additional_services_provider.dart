import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_additional_service_model.dart';
import 'package:proplilly/client/services/client_additional_services_service.dart';

class ClientAdditionalServicesProvider extends ChangeNotifier {
  ClientAdditionalServicesProvider({ClientAdditionalServicesService? service})
      : _service = service ?? ClientAdditionalServicesService();

  final ClientAdditionalServicesService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClientAdditionalService> _services = <ClientAdditionalService>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClientAdditionalService> get services =>
      List<ClientAdditionalService>.unmodifiable(_services);
  bool get hasData => _services.isNotEmpty && _errorMessage == null;

  Future<void> loadAdditionalServices() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _services = <ClientAdditionalService>[];
    notifyListeners();

    final result = await _service.fetchAdditionalServices();

    _isLoading = false;

    switch (result) {
      case ClientAdditionalServicesFetchSuccess(:final model):
        _services = List<ClientAdditionalService>.from(model.data);
        _errorMessage = null;
      case ClientAdditionalServicesFetchFailure(:final message):
        _services = <ClientAdditionalService>[];
        _errorMessage = message.trim().isNotEmpty ? message.trim() : null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadAdditionalServices();
}
