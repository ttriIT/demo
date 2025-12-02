import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  DateFormatter._();
  
  /// Format timestamp for chat messages (e.g., "10:30 AM" or "Yesterday" or "Jan 15")
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      // Same day: show time only
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within a week: show day name
      return DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      // Same year: show month and day
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Different year: show full date
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }
  
  /// Format chat bubble timestamp (e.g., "10:30 AM")
  static String formatBubbleTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  /// Format last seen (e.g., "Active now" or "Active 5m ago")
  static String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return 'Active ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Active ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Active ${difference.inDays}d ago';
    } else {
      return 'Offline';
    }
  }
}
