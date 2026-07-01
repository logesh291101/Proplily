import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_market_lines_model.dart';
import 'package:proplilly/client/services/client_market_lines_service.dart';

/// Loads market headlines for the Client home screen.
class ClientHomeMarketHeadlinesProvider extends ChangeNotifier {
  ClientHomeMarketHeadlinesProvider({ClientMarketLinesService? service})
      : _service = service ?? ClientMarketLinesService();

  final ClientMarketLinesService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClientMarketHeadline> _headlines = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClientMarketHeadline> get headlines =>
      List<ClientMarketHeadline>.unmodifiable(_headlines);
  bool get hasHeadlines => _headlines.isNotEmpty;

  bool get shouldShowSection =>
      _isLoading || _errorMessage != null || hasHeadlines;

  Future<void> loadHeadlines() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.fetchHeadlines();
    _isLoading = false;

    switch (result) {
      case ClientMarketLinesFetchSuccess(:final model):
        _headlines = model.data;
        _errorMessage = null;
      case ClientMarketLinesFetchFailure(:final message):
        _headlines = const [];
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadHeadlines();
}
