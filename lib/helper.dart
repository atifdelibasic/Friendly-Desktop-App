import 'package:intl/intl.dart';

String formatDateString(String dateString) {
  // Parse the string into a DateTime object
  DateTime parsedDate = DateTime.parse(dateString);
  
  // Format the DateTime object into a desired string format
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
  
  return formattedDate;
}