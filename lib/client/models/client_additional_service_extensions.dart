import 'package:proplilly/client/models/client_additional_service_model.dart';
import 'package:proplilly/client/models/client_ticket_extensions.dart';

extension ClientAdditionalServiceUi on ClientAdditionalService {
  String get displayServiceType {
    final value = serviceType.trim();
    return value.isNotEmpty ? value : '—';
  }

  String? get displayComments {
    final value = comments?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String get formattedCreatedAt => formatClientTicketDate(createdAt);
}
