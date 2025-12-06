import 'package:intl/intl.dart';

/// Utility class for date and time formatting
/// Centralizes all date formatting logic
class DateFormatter {
  /// Format DateTime to readable string
  /// Example: "12:30 PM" or "2:45 AM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Format DateTime to readable date string
  /// Example: "Dec 6, 2025"
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  /// Format DateTime to complete readable string
  /// Example: "Dec 6, 2025 at 2:45 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y \'at\' hh:mm a').format(dateTime);
  }

  /// Format DateTime relative to now
  /// Example: "2 minutes ago", "Yesterday", etc.
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(dateTime);
    }
  }
}
