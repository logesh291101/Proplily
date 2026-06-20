/// A submitted client feedback entry.
class FeedbackEntry {
  const FeedbackEntry({
    required this.rating,
    required this.message,
    required this.submittedAt,
  });

  final int rating;
  final String message;
  final DateTime submittedAt;

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = submittedAt;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
