import 'package:date_format/date_format.dart';

class DateTimeHelper {
  static String convertTimeToString(int time) {
    return convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(time * 1000));
  }

  static String convertDateTimeToString(DateTime date) {
    return formatDate(
        date, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }

  //2018-12-17 18:03:26 +0800 input
  static DateTime convertStringTimeToDateTime(String string) {
      return DateTime.parse(string).toLocal();
  }

  static String convertTimeToDisplayString(DateTime date) {
    if (isToday(date))
      return formatDate(date, ['Today, ', h, ':', nn, ' ', am]);
    else
      return formatDate(date, [D, ', ', dd, '-', m, ' ', h, ':', nn, ' ', am]);
  }

  static String convertDoubleTimeToDisplayString(DateTime start, DateTime end) {
    if (isToday(start))
      return formatDate(start, ['Today, ', h, ':', nn, ' ', am]) +
          " to " +
          formatDate(end, [h, ':', nn, ' ', am]);
    else
      return formatDate(
              start, [D, ', ', dd, '-', m, ' ', h, ':', nn, ' ', am]) +
          " to " +
          formatDate(end, [h, ':', nn, ' ', am]);
  }



  static bool isToday(DateTime time) {
    DateTime today = DateTime.now();
    return (time.day == today.day &&
        time.month == today.month &&
        time.year == today.year);
  }
}
