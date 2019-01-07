import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateTime convertEpochTimeToDateTime(String epoch) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(epoch));
  }

  static String convertEpochSecondsToDateTimeString(int epoch) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    return convertTimeToDisplayString(date);
  }

  static String convertDateTimeToWeek(DateTime datetime) {
    return formatDate(datetime, [yyyy, '_WEEK_', WW]);
  }

  static String convertDateTimeToAMPM(DateTime date) {
    return DateFormat.jm().format(date);
  }

  static String convertDateTimeToStorageString(DateTime date) {
    return formatDate(date, [yyyy, mm, dd]);
  }

  static String convertDateTimeToDate(DateTime date) {
    if (isToday(date))
      return formatDate(date, ['Today, ', dd, '-', mm]);
    else
      return formatDate(date, [D, ', ', dd, '-', mm]);
  }

    static String convertDateTimeToNewLineDate(DateTime date) {
    if (isToday(date))
      return formatDate(date, ['Today,\n', dd, '-', mm]);
    else
      return formatDate(date, [D, ',\n', dd, '-', mm]);
  }

  static String convertDateTimeToDateAndYear(DateTime date) {
    return formatDate(date, [dd, '-', MM, '-', yyyy]);
  }

  static String convertDateTimeToString(DateTime date) {
    return formatDate(
        date, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }

  static String convertDateTimeToTime(DateTime date) {
    return formatDate(date, [date.hour == 12 ? "12" : hh, ':', nn, ' ', am]);
  }

  static String convertDateTimeTo24Hour(DateTime date) {
    return formatDate(date, [HH]);
  }

  static String convertDateTimeToMinute(DateTime date) {
    return formatDate(date, [nn]);
  }

  // //2018-12-17 18:03:26 +0800 input
  // static DateTime convertStringTimeToDateTime(String string) {
  //   return DateTime.parse(string).toLocal();
  // }

  static String convertTimeToDisplayString(DateTime date) {
    if (isToday(date))
      return formatDate(
          date, ['Today, ', date.hour == 12 ? "12" : hh, ':', nn, am]);
    else
      return formatDate(date,
          [D, ', ', dd, '-', mm, ' ', date.hour == 12 ? "12" : hh, ':', nn, am]);
  }

  static String convertStartTimeToDisplayString(DateTime date) {
    if (isToday(date))
      return formatDate(
          date, ['Today, ', date.hour == 12 ? "12" : hh, ':', nn, am]);
    else
      return formatDate(date,
          [D, ', ', dd, '-', m, ' ', date.hour == 12 ? "12" : hh, ':', nn, am]);
  }

  static String convertEndTimeToDisplayString(DateTime date) {
    if (isToday(date))
      return formatDate(
          date, ['Today, ', date.hour == 12 ? "12" : hh, ':', nn, am]);
    else
      return formatDate(date,
          [D, ', ', dd, '-', m, ' ', date.hour == 12 ? "12" : hh, ':', nn, am]);
  }

  static String convertDoubleTimeToDisplayString(DateTime start, DateTime end) {
    if (isToday(start))
      return formatDate(
              start, ['Today, ', start.hour == 12 ? "12" : hh, ':', nn, am]) +
          " to " +
          formatDate(end, [end.hour == 12 ? "12" : hh, ':', nn, am]);
    else
      return formatDate(start, [
            D,
            ', ',
            dd,
            '-',
            mm,
            ' ',
            start.hour == 12 ? "12" : hh,
            ':',
            nn,
            am
          ]) +
          " to " +
          formatDate(end, [end.hour == 12 ? "12" : hh, ':', nn, am]);
  }

  static String convertDoubleTime2ToDisplayString(
      DateTime start, DateTime end) {
    if (isToday(start))
      return formatDate(
              start, ['Today, ', start.hour == 12 ? "12" : hh, ':', nn, am]) +
          " - " +
          formatDate(end, [end.hour == 12 ? "12" : hh, ':', nn, am]);
    else
      return formatDate(start, [
            D,
            ', ',
            dd,
            '-',
            m,
            ' ',
            start.hour == 12 ? "12" : hh,
            ':',
            nn,
            am
          ]) +
          " - " +
          formatDate(end, [end.hour == 12 ? "12" : hh, ':', nn, am]);
  }

  static bool isToday(DateTime time) {
    DateTime today = DateTime.now();
    return (time.day == today.day &&
        time.month == today.month &&
        time.year == today.year);
  }

  static bool sameDay(DateTime time, DateTime other) {
    return (time.day == other.day &&
        time.month == other.month &&
        time.year == other.year);
  }

  static bool isTomorrow(DateTime time) {
    DateTime today = DateTime.now().add(Duration(days: 1));
    return (time.day == today.day &&
        time.month == today.month &&
        time.year == today.year);
  }
}
