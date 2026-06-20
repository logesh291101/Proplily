import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_tickets_model.dart';
import 'package:proplilly/client/services/client_ticket_list_service.dart';

class TicketListProvider extends ChangeNotifier {
  TicketListProvider({TicketListService? ticketListService})
      : _ticketListService = ticketListService ?? TicketListService();

  final TicketListService _ticketListService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientTicketsModel? _ticketsModel;
  List<ClientTicketData> _loadedTickets = <ClientTicketData>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientTicketsModel? get ticketsModel => _ticketsModel;
  List<ClientTicketData> get tickets => List.unmodifiable(_loadedTickets);
  bool get hasData => _ticketsModel != null && _errorMessage == null;

  ClientTicketData? ticketById(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    for (final ticket in _loadedTickets) {
      if (ticket.id?.trim() == normalized) return ticket;
    }
    return null;
  }

  Future<void> loadTickets() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _ticketListService.fetchTickets();

    _isLoading = false;

    switch (result) {
      case TicketListFetchSuccess(:final model):
        _ticketsModel = model;
        _loadedTickets = List<ClientTicketData>.from(model.data ?? const []);
        _errorMessage = null;
      case TicketListFetchFailure(:final message):
        _ticketsModel = null;
        _loadedTickets = <ClientTicketData>[];
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadTickets();
}
