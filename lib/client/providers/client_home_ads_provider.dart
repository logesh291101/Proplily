import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_ads_model.dart';
import 'package:proplilly/client/services/client_ads_service.dart';

/// Loads ads for the Client home screen slider.
class ClientHomeAdsProvider extends ChangeNotifier {
  ClientHomeAdsProvider({ClientAdsService? service})
      : _service = service ?? ClientAdsService();

  final ClientAdsService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClientAdData> _ads = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClientAdData> get ads => List<ClientAdData>.unmodifiable(_ads);
  bool get hasAds => _ads.isNotEmpty;

  Future<void> loadAds() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.fetchAds();
    _isLoading = false;

    switch (result) {
      case ClientAdsFetchSuccess(:final model):
        _ads = model.data ?? const [];
        _errorMessage = null;
      case ClientAdsFetchFailure(:final message):
        _ads = const [];
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadAds();
}
