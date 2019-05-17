import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final _numberFormatCompact = NumberFormat.compact();

DateTime secondsToDateTime(int secondsSinceEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);

String formatNumber(dynamic value) => _numberFormatCompact.format(value);

String formatTimestamp(int timestamp) {
  if (timestamp == null) return '';

  final d = secondsToDateTime(timestamp);
  if (DateTime.now().subtract(Duration(days: 30)).isBefore(d)) {
    return timeago.format(d);
  }
  
  // TODO: use date format from device locale
  return "${d.day}/${d.month}/${d.year}";
}
    
