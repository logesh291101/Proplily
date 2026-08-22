import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_property_status_model.dart';
import 'package:proplilly/client/services/client_property_status_service.dart';

class PropertyStatusProvider extends ChangeNotifier {
  PropertyStatusProvider({PropertyStatusService? propertyStatusService})
      : _propertyStatusService =
            propertyStatusService ?? PropertyStatusService();

  final PropertyStatusService _propertyStatusService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _emptyMessage;
  List<ClientPropertyStatus> _properties = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get emptyMessage => _emptyMessage;
  List<ClientPropertyStatus> get properties {
    _ensureValidProperties();
    return List<ClientPropertyStatus>.unmodifiable(_properties);
  }

  /// Clears stale list instances left by hot reload after model migrations.
  void _ensureValidProperties() {
    try {
      _properties = List<ClientPropertyStatus>.from(_properties);
    } catch (_) {
      _properties = <ClientPropertyStatus>[];
    }
  }

  bool get hasProperties {
    _ensureValidProperties();
    return _properties.isNotEmpty && _errorMessage == null;
  }

  Future<void> loadPropertyStatus() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _emptyMessage = null;
    _properties = <ClientPropertyStatus>[];
    notifyListeners();

    final result = await _propertyStatusService.fetchPropertyStatus();

    _isLoading = false;

    switch (result) {
      case PropertyStatusFetchSuccess(:final model):
        _properties = List<ClientPropertyStatus>.from(model.data);
        _errorMessage = null;
        if (model.data.isEmpty) {
          final msg = model.message.trim();
          _emptyMessage = msg.isNotEmpty ? msg : null;
        } else {
          _emptyMessage = null;
        }
      case PropertyStatusFetchFailure(:final message):
        _properties = <ClientPropertyStatus>[];
        _errorMessage = message;
        _emptyMessage = null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadPropertyStatus();
}
