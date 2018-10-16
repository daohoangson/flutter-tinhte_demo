import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final _numberFormatCompact = NumberFormat.compact();

String formatNumber(dynamic value) => _numberFormatCompact.format(value);

String formatTimestamp(int timestamp) => timestamp != null
    ? timeago.format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000))
    : '';
