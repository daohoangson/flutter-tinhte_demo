import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

final _numberFormatCompact = NumberFormat.compact();

class L10n {
  L10n(this.localeName);

  final String localeName;

  String get title => Intl.message('Tinh tế Demo',
      desc: 'Title of the app', locale: localeName);

  static Future<L10n> load(Locale locale) {
    final localeName = Intl.canonicalizedLocale(
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString());
    return initializeMessages(localeName).then((_) => L10n(localeName));
  }

  static L10n of(BuildContext context) => Localizations.of<L10n>(context, L10n);
}

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) => [
        'en',
        'vi',
      ].contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) => L10n.load(locale);

  @override
  bool shouldReload(L10nDelegate old) => false;
}

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
