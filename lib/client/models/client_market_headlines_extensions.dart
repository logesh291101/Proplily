import 'package:intl/intl.dart';
import 'package:proplilly/client/models/client_market_lines_model.dart';

extension ClientMarketHeadlineUi on ClientMarketHeadline {
  String get displayLocation {
    final value = category.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displayTitle {
    final value = title.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get displaySource {
    final value = authorName.trim();
    return value.isNotEmpty ? value : '—';
  }

  String get relativePublishedTime => formatMarketHeadlineRelativeTime(createdAt);

  String get formattedPublishedDate =>
      formatMarketHeadlinePublishedDate(createdAt);

  String get sourceWithTime {
    final source = authorName.trim();
    final time = relativePublishedTime;
    if (source.isEmpty && time.isEmpty) return '—';
    if (source.isEmpty) return time;
    if (time.isEmpty) return source;
    return '$source • $time';
  }

  String get cardImageUrl {
    final small = smallImage.trim();
    if (small.isNotEmpty) return small;
    return largeImage.trim();
  }

  List<String> get detailImageUrls {
    final large = largeImage.trim();
    if (large.isEmpty) return const [];
    return [large];
  }

  String get displayContent {
    final full = fullDescription.trim();
    if (full.isNotEmpty) return full;
    return shortDescription.trim();
  }
}

String formatMarketHeadlineRelativeTime(String? raw) {
  final trimmed = raw?.trim() ?? '';
  if (trimmed.isEmpty) return '';

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return trimmed;

  final now = DateTime.now();
  final difference = now.difference(parsed);

  if (difference.inDays > 0) {
    final days = difference.inDays;
    return days == 1 ? '1 day ago' : '$days days ago';
  }
  if (difference.inHours > 0) {
    final hours = difference.inHours;
    return hours == 1 ? '1 hour ago' : '$hours hours ago';
  }
  if (difference.inMinutes > 0) {
    final minutes = difference.inMinutes;
    return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
  }
  return 'Just now';
}

String formatMarketHeadlinePublishedDate(String? raw) {
  final trimmed = raw?.trim() ?? '';
  if (trimmed.isEmpty) return '—';

  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return trimmed;

  return DateFormat('dd MMM yyyy').format(parsed);
}
