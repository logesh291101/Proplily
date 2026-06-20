import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_properties_model.dart';
import 'package:proplilly/client/services/client_my_properties_service.dart';

/// Loads properties for the Client home carousel.
class ClientHomePropertiesProvider extends ChangeNotifier {
  ClientHomePropertiesProvider({ClientMyPropertiesService? service})
      : _service = service ?? ClientMyPropertiesService();

  final ClientMyPropertiesService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClientProperty> _loadedProperties = <ClientProperty>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClientProperty> get properties =>
      List<ClientProperty>.unmodifiable(_loadedProperties);
  bool get hasData => _loadedProperties.isNotEmpty;

  Future<void> loadProperties() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.fetchProperties();
    _isLoading = false;

    switch (result) {
      case ClientPropertiesFetchSuccess(:final model):
        _loadedProperties = List<ClientProperty>.from(model.data ?? const []);
        _errorMessage = null;
      case ClientPropertiesFetchFailure(:final message):
        _loadedProperties = <ClientProperty>[];
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadProperties();
}
