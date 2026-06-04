import 'package:flutter/foundation.dart';
import 'package:proplilly/models/client_tickets_model.dart';
import 'package:proplilly/services/ticket_list_service.dart';

class TicketListProvider extends ChangeNotifier {
  TicketListProvider({TicketListService? ticketListService})
      : _ticketListService = ticketListService ?? TicketListService();

  final TicketListService _ticketListService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientTicketsModel? _ticketsModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientTicketsModel? get ticketsModel => _ticketsModel;

  List<ClientTicket> get tickets => _ticketsModel?.tickets ?? [];

  bool get hasData => _ticketsModel != null && _errorMessage == null;

  ClientTicket? ticketById(String id) {
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    for (final ticket in tickets) {
      if (ticket.id == normalized) return ticket;
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
        _errorMessage = null;
      case TicketListFetchFailure(:final message):
        _ticketsModel = null;
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadTickets();
}
