import 'package:intl/intl.dart';

class DateFormatter {
  // Default format based on the locale of the device
  static String defaultFormat(DateTime dateTime) {
    return DateFormat.yMd().format(dateTime);
  }

  // ISO 8601 format
  static String iso8601Format(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ssZ').format(dateTime);
  }

  // Long date format (e.g., December 31, 2022)
  static String longDateFormat(DateTime dateTime) {
    return DateFormat.yMMMMd().format(dateTime);
  }

  // Short date format (e.g., Dec 31, 2022)
  static String shortDateFormat(DateTime dateTime) {
    return DateFormat.yMMMd().format(dateTime);
  }

  // Time format (e.g., 23:59:59)
  static String timeFormat(DateTime? dateTime) {
    return DateFormat.Hms().format(dateTime!);
  }

  static String timeFormat12Hour(DateTime? dateTime) {
    return DateFormat('hh:mm a').format(dateTime!);
  }

  // Custom format (e.g., Saturday, December 31, 2022)
  static String customFormat(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy').format(dateTime);
  }

  static String dayMonthYearFormat(DateTime? dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime!);
  }

  //SHOWING THE DATE TIME LIKE THIS (24-04-2025 04:56:60) (dd-MM-yyyy HH:MM:SS)
  static String formatDateTime(DateTime? dateTime) {
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime!);
  }

  static DateTime dayMonthYearToDateTime(String dateString) {
    return DateFormat('dd-MM-yyyy').parse(dateString);
  }

  static double calculateTimeDifference(String time1, String time2) {
    int hour1 = int.parse(time1.split(':')[0]);
    int minute1 = int.parse(time1.split(':')[1].split(' ')[0]);
    String ampm1 = time1.split(' ')[1];

    int hour2 = int.parse(time2.split(':')[0]);
    int minute2 = int.parse(time2.split(':')[1].split(' ')[0]);
    String ampm2 = time2.split(' ')[1];

    if (ampm1 == 'PM' && hour1 != 12) hour1 += 12;
    if (ampm2 == 'PM' && hour2 != 12) hour2 += 12;

    int totalMinutes1 = hour1 * 60 + minute1;
    int totalMinutes2 = hour2 * 60 + minute2;
    int differenceInMinutes = (totalMinutes2 - totalMinutes1).abs();

    // Convert difference to decimal hours
    double differenceInHours = differenceInMinutes / 60.0;

    return differenceInHours;
  }

  static int calculateDays(String fromDateStr, String toDateStr) {
    if (fromDateStr.isNotEmpty && toDateStr.isNotEmpty) {
      List<int> fromDateParts = fromDateStr.split('-').map(int.parse).toList();
      List<int> toDateParts = toDateStr.split('-').map(int.parse).toList();

      DateTime fromDate =
          DateTime(fromDateParts[2], fromDateParts[1], fromDateParts[0]);
      DateTime toDate =
          DateTime(toDateParts[2], toDateParts[1], toDateParts[0]);

      Duration difference = toDate.difference(fromDate);

      return difference.inDays + 1;
    } else {
      return 0;
    }
  }

  static String formatTimeOfDaysAsString(String? timeStr) {
    // Parse the input time string
    final timeParts = timeStr!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Calculate the hour of the period
    final hourOfPeriod = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'AM' : 'PM';

    // Return the formatted time string
    return '$hourOfPeriod:$minuteStr $period';
  }
}
