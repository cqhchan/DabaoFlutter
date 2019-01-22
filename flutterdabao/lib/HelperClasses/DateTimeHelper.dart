import 'package:date_format/date_format.dart';
import 'package:flutterdabao/HelperClasses/StringHelper.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {

  // to tell what week it is
  static String convertDateTimeToWeek(DateTime datetime) {
    //TODO p1 check the transactions
    DateTime newDate = DateTime.utc(datetime.toUtc().year, datetime.toUtc().month,datetime.toUtc().day);
    return formatDate(newDate, [yyyy, '_WEEK_', WW]);
  }

  // returns 3 hours ago/ years ago etc
  static String convertDateTimeToAgo(DateTime datetime) {
    Duration diff = DateTime.now().difference(datetime);

    double timeLeftinSecond = diff.inMilliseconds / 1000;

    double secondPerMinute = 60.0;
    double minutePerHour = 60.0;
    double hourPerDay = 24.0;
    double dayPerWeek = 7.0;
    double weekPerYear = 53.0;

    if (isToday(datetime)) {
      if (timeLeftinSecond < secondPerMinute)
        return timeLeftinSecond.toString() + ' seconds ago';
      if (timeLeftinSecond >= secondPerMinute &&
          timeLeftinSecond < secondPerMinute * minutePerHour)
        return (timeLeftinSecond / secondPerMinute).round().toString() +
            ' minute(s) ago';
      if (timeLeftinSecond >= secondPerMinute * minutePerHour &&
          timeLeftinSecond < secondPerMinute * minutePerHour * hourPerDay)
        return (timeLeftinSecond / (secondPerMinute * minutePerHour))
                .round()
                .toString() +
            ' hour(s) ago';
    }

    if (timeLeftinSecond >= (secondPerMinute * minutePerHour * hourPerDay) &&
        timeLeftinSecond <
            (secondPerMinute * minutePerHour * hourPerDay * dayPerWeek))
      return (timeLeftinSecond / (secondPerMinute * minutePerHour * hourPerDay))
              .ceil()
              .toString() +
          ' day(s) ago';
    if (timeLeftinSecond >=
            (secondPerMinute * minutePerHour * hourPerDay * dayPerWeek) &&
        timeLeftinSecond <
            (secondPerMinute *
                minutePerHour *
                hourPerDay *
                dayPerWeek *
                weekPerYear))
      return (timeLeftinSecond /
                  (secondPerMinute * minutePerHour * hourPerDay * dayPerWeek))
              .ceil()
              .toString() +
          ' week(s) ago';
    if (timeLeftinSecond >=
        (secondPerMinute *
            minutePerHour *
            hourPerDay *
            dayPerWeek *
            weekPerYear))
      return (timeLeftinSecond /
                  (secondPerMinute * minutePerHour * hourPerDay * dayPerWeek))
              .ceil()
              .toString() +
          ' year(s) ago';

    return 'Please try again.';
  }

  // 12:12am
  static String convertDateTimeToAMPM(DateTime date) {
    return DateFormat.jm().format(date);
  }

  // 12:12 no am even though its am/pm
  static String hourAndMin12Hour(DateTime date) {
    return formatDate(date, [date.hour == 0 || date.hour == 12 ? "12" : hh, ":", nn]);
  }

    // 12:12 no am even though its am/pm
  static String hourAndMinSecond12Hour(DateTime date) {
    return formatDate(date, [date.hour == 0 || date.hour == 12 ? "12" : hh, ":", nn, ":", ss]);
  }

  // Today or 14 Jan
  static String convertDateTimeToDate(DateTime date) {
    if (isToday(date))
      return "Today";
    else
      return StringHelper.upperCaseWords(formatDate(date, [d, ' ', M]))  ;
  }


  // Today or 14 Jan
  static String confirmationProofDate(DateTime date) {
    if (isToday(date))
      return "Today, " + StringHelper.upperCaseWords(formatDate(date, [d, ' ', M]));
    else
      return StringHelper.upperCaseWords(formatDate(date, [d, ' ', M]))  ;
  }



  //important for cloud functions
  static String convertDateTimeToString(DateTime date) {
    return formatDate(
        date, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss, ' ', z]);
  }



  // //2018-12-17 18:03:26 +0800 input
  // static DateTime convertStringTimeToDateTime(String string) {
  //   return DateTime.parse(string).toLocal();
  // }

  static String convertTimeToDisplayString(DateTime date) {
  return convertDateTimeToDate(date) + ", " + convertDateTimeToAMPM(date);
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
   return convertTimeToDisplayString(start) + " to " + convertDateTimeToAMPM(end);
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
