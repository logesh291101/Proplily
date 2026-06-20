import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_feedback_history_model.dart';
import 'package:proplilly/client/services/client_feedback_service.dart';

class ClientFeedbackProvider extends ChangeNotifier {
  ClientFeedbackProvider({ClientFeedbackService? clientFeedbackService})
      : _clientFeedbackService =
            clientFeedbackService ?? ClientFeedbackService();

  final ClientFeedbackService _clientFeedbackService;

  bool _isLoadingHistory = false;
  String? _historyErrorMessage;
  List<FeedbackHistory> _historyRecords = [];
  String? _emptyHistoryMessage;

  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyErrorMessage => _historyErrorMessage;
  List<FeedbackHistory> get historyRecords => _historyRecords;
  String? get emptyHistoryMessage => _emptyHistoryMessage;

  bool get hasHistoryRecords =>
      _historyRecords.isNotEmpty && _historyErrorMessage == null;

  Future<ClientFeedbackResult> submitFeedback({
    required int rating,
    required String feedbackMessage,
  }) {
    return _clientFeedbackService.submitFeedback(
      rating: rating,
      feedbackMessage: feedbackMessage,
    );
  }

  Future<void> loadFeedbackHistory() async {
    if (_isLoadingHistory) return;

    _isLoadingHistory = true;
    _historyErrorMessage = null;
    notifyListeners();

    final result = await _clientFeedbackService.fetchFeedbackHistory();

    _isLoadingHistory = false;

    switch (result) {
      case ClientFeedbackHistoryFetchSuccess(:final model):
        _historyRecords = model.data;
        _historyErrorMessage = null;
        _emptyHistoryMessage = model.data.isEmpty
            ? (model.message.trim().isNotEmpty ? model.message.trim() : null)
            : null;
      case ClientFeedbackHistoryFetchFailure(:final message):
        _historyRecords = [];
        _historyErrorMessage = message;
        _emptyHistoryMessage = null;
    }

    notifyListeners();
  }

  Future<void> refreshHistory() => loadFeedbackHistory();
}
