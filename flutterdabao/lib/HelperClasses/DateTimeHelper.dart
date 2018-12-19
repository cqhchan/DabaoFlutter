import 'package:date_format/date_format.dart';

class DateTimeHelper {
  static String convertTimeToString(int time) {
    return formatDate(DateTime.fromMillisecondsSinceEpoch(time * 1000),
        [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }
}
