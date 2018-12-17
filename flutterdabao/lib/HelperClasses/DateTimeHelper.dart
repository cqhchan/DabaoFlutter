import 'package:date_format/date_format.dart';

class DateTimeHelper {
  static String convertTimeToString(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time * 1000),
        [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }

  static String convertDateTimeToString(DateTime date) {
    return formatDate(date,
        [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }

  static String convertTimeToDisplayString(DateTime date) {
    if (isToday(date))
      return formatDate(date, ['Today, ', h, ':', nn, ' ', am]);
    else
      return formatDate(date, [D, ', ', dd, '-', m, ' ', h, ':', nn, ' ', am]);
  }

  static bool isToday(DateTime time) {
    DateTime today = DateTime.now();
    return (time.day == today.day &&
        time.month == today.month &&
        time.year == today.year);
  }
}
