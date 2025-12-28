import 'package:intl/intl.dart';

class DateTimeFormattingHelper {

   static String formatDate(date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formattedDuration(duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}