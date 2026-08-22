import 'package:flutter/foundation.dart';
import 'package:proplilly/client/models/client_support_ticket_model.dart';
import 'package:proplilly/client/models/client_ticket_extensions.dart';
import 'package:proplilly/client/services/client_ticket_list_service.dart';

class TicketListProvider extends ChangeNotifier {
  TicketListProvider({TicketListService? ticketListService})
      : _ticketListService = ticketListService ?? TicketListService();

  final TicketListService _ticketListService;

  bool _isLoading = false;
  String? _errorMessage;
  ClientSupportTicketModel? _ticketsModel;
  List<ClientSupportTicket> _loadedTickets = <ClientSupportTicket>[];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClientSupportTicketModel? get ticketsModel => _ticketsModel;
  List<ClientSupportTicket> get tickets {
    _coerceLoadedTickets();
    return List.unmodifiable(_loadedTickets);
  }

  bool get hasData => _ticketsModel != null && _errorMessage == null;

  ClientSupportTicket? ticketById(String id) {
    _coerceLoadedTickets();
    final normalized = id.trim();
    if (normalized.isEmpty) return null;

    for (final ticket in _loadedTickets) {
      if (ticket.id.trim() == normalized) return ticket;
    }
    return null;
  }

  void _coerceLoadedTickets() {
    if (_loadedTickets.isEmpty) return;

    final rawList = _loadedTickets as List<dynamic>;
    if (rawList.every((ticket) => ticket is ClientSupportTicket)) return;

    try {
      _loadedTickets = normalizeSupportTicketList(rawList);
    } catch (_) {
      _loadedTickets = <ClientSupportTicket>[];
      _ticketsModel = null;
    }
  }

  Future<void> loadTickets() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    _loadedTickets = <ClientSupportTicket>[];
    notifyListeners();

    final result = await _ticketListService.fetchTickets();

    _isLoading = false;

    switch (result) {
      case TicketListFetchSuccess(:final model):
        _ticketsModel = model;
        _loadedTickets = List<ClientSupportTicket>.from(model.data);
        _errorMessage = null;
      case TicketListFetchFailure(:final message):
        _ticketsModel = null;
        _loadedTickets = <ClientSupportTicket>[];
        _errorMessage = message;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadTickets();
}
