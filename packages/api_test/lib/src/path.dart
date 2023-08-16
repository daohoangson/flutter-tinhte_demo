import 'package:path/path.dart' as p;

final mocksParts = List.unmodifiable(['packages', 'api_test', 'mocks']);

String getFilePath(Uri uri, {String suffix = ''}) {
  final parts = p
      .split(uri.path)
      .where(
        (part) =>
            part.isNotEmpty &&
            part != '/' &&
            part != 'appforo' &&
            part != 'index.php',
      )
      .toList();
  final queryKeys = <String>[];
  final queryParameters = uri.queryParameters;
  for (final key in queryParameters.keys) {
    if (key == 'oauth_token') continue;
    if (queryParameters[key] == '') {
      if (uri.path.endsWith('index.php')) {
        // take empty query as direct part for URLs like `/api/index.php?route/foo`
        parts.addAll(p.split(key));
      }
    } else {
      queryKeys.add(key);
    }
  }

  // sort query keys before building path
  queryKeys.sort();
  for (final key in queryKeys) {
    parts.add('$key=${queryParameters[key]}');
  }

  final lastPart = parts.removeLast();
  final cleanedUp = _cleanUpParts([...parts, '$lastPart$suffix']);
  return p.joinAll([...mocksParts, ...cleanedUp]);
}

List<String> _cleanUpParts(Iterable<String> parts) {
  var cleanedUp = parts
      .map((e) => e.replaceAll(RegExp('[:]'), '_'))
      .toList(growable: false);

  if (cleanedUp.length > 4 &&
      cleanedUp[0].length == 43 &&
      cleanedUp[2] == 'plain' &&
      cleanedUp[3] == 'https_') {
    // remove some parts from resized URLs
    // e.g. `abcxyz/rs_fill_123_456_0/plain/https_/domain.com`
    final resizeConfig = cleanedUp[1];
    final importantParts = cleanedUp.skip(5).toList();
    final lastPart = importantParts.removeLast();
    cleanedUp = [...importantParts, resizeConfig, lastPart];
  }

  if (cleanedUp.length >= 3 &&
      cleanedUp[0] == 'attachments' &&
      cleanedUp[2] == 'data') {
    final attachmentId = cleanedUp[1];
    final rest = cleanedUp.skip(3).toList(growable: false);
    cleanedUp = [
      'attachments',
      attachmentId,
      ...rest,
      rest.isEmpty ? 'data.jpg' : 'thumbnail.jpg',
    ];
  }

  return cleanedUp;
}
