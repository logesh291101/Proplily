/// FAQ entry for the client support ticket hub.
class ClientSupportTicketFaqItem {
  const ClientSupportTicketFaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

/// A resolved support ticket in history.
class ClientSupportTicketResolutionItem {
  const ClientSupportTicketResolutionItem({
    required this.status,
    required this.date,
    required this.subject,
    required this.description,
  });

  final String status;
  final String date;
  final String subject;
  final String description;

  bool get isResolved => status.toLowerCase() == 'resolved';
}

/// Static UI content for [ClientSupportTicketScreen].
class ClientSupportTicketContent {
  ClientSupportTicketContent._();

  static const String phone = '+1 (234) 567-890';
  static const String email = 'support@proplilly.com';

  static const List<String> ticketCategories = [
    'Technical Issue',
    'Property Related',
    'Billing & Payments',
    'Other Enquiry',
  ];

  static const List<ClientSupportTicketFaqItem> faqs = [
    ClientSupportTicketFaqItem(
      question: 'How often are inspections?',
      answer:
          'Routine inspections are typically scheduled quarterly. Additional '
          'visits may be arranged on request or when flagged by your property manager.',
    ),
    ClientSupportTicketFaqItem(
      question: 'What documents do I need?',
      answer:
          'Common documents include proof of ownership, identity verification, '
          'tax records, and any prior inspection reports. Your dashboard lists '
          'required items specific to your properties.',
    ),
  ];

  static const ClientSupportTicketResolutionItem sampleResolution =
      ClientSupportTicketResolutionItem(
    status: 'Resolved',
    date: 'Apr 30, 2026',
    subject: 'Other issues',
    description: 'Testing purpose',
  );
}
