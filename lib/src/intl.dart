import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final _numberFormatCompact = NumberFormat.compact();

DateTime secondsToDateTime(int secondsSinceEpoch) =>
    DateTime.fromMillisecondsSinceEpoch(secondsSinceEpoch * 1000);

String formatNumber(dynamic value) => _numberFormatCompact.format(value);

String formatTimestamp(int timestamp) =>
    timestamp != null ? timeago.format(secondsToDateTime(timestamp)) : '';
