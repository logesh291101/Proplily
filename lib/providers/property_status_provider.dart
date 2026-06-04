import 'package:flutter/foundation.dart';
import 'package:proplilly/models/client_property_status_model.dart';
import 'package:proplilly/services/property_status_service.dart';

class PropertyStatusProvider extends ChangeNotifier {
  PropertyStatusProvider({PropertyStatusService? propertyStatusService})
      : _propertyStatusService =
            propertyStatusService ?? PropertyStatusService();

  final PropertyStatusService _propertyStatusService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _emptyMessage;
  List<ClientPropertyStatusItem> _properties = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get emptyMessage => _emptyMessage;
  List<ClientPropertyStatusItem> get properties => _properties;

  bool get hasProperties =>
      _properties.isNotEmpty && _errorMessage == null;

  Future<void> loadPropertyStatus() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _emptyMessage = null;
    notifyListeners();

    final result = await _propertyStatusService.fetchPropertyStatus();

    _isLoading = false;

    switch (result) {
      case PropertyStatusFetchSuccess(:final model):
        _properties = model.data;
        _errorMessage = null;
        if (model.data.isEmpty) {
          final msg = model.message.trim();
          _emptyMessage = msg.isNotEmpty ? msg : null;
        } else {
          _emptyMessage = null;
        }
      case PropertyStatusFetchFailure(:final message):
        _properties = [];
        _errorMessage = message;
        _emptyMessage = null;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadPropertyStatus();
}
