import 'package:flutter/foundation.dart';
import 'package:proplilly/client/services/client_support_ticket_service.dart';

class ClientSupportTicketProvider extends ChangeNotifier {
  ClientSupportTicketProvider({ClientSupportTicketService? clientSupportTicketService})
      : _clientSupportTicketService =
            clientSupportTicketService ?? ClientSupportTicketService();

  final ClientSupportTicketService _clientSupportTicketService;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  Future<ClientSupportTicketResult> submitTicket({
    required String subject,
    required String category,
    required String message,
  }) async {
    if (_isSubmitting) {
      return const ClientSupportTicketFailure(message: null);
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      return await _clientSupportTicketService.submitTicket(
        subject: subject.trim(),
        category: category.trim(),
        message: message.trim(),
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
