import 'package:timeago/timeago.dart' as timeago;

class TimeFormatter {

  TimeFormatter._();
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diference = now.difference(date);

    if (diference.inDays < 30) {
      return timeago.format(date, locale: 'es');
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
  }
}
