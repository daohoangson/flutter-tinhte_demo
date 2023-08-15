final mocksParts = List.unmodifiable(['packages', 'api_test', 'mocks']);

Iterable<String> cleanUpParts(Iterable<String> parts) {
  var cleanedUp = parts
      .map((e) => e.replaceAll(RegExp('[:]'), '_'))
      .toList(growable: false);

  if (cleanedUp.length > 2 &&
      cleanedUp[0].length == 43 &&
      cleanedUp[1].startsWith('rs_') &&
      cleanedUp[2] == 'plain' &&
      cleanedUp[3] == 'https_') {
    // remove some parts from resized URLs
    // e.g. `abcxyz/rs_fill_123_456_0/plain/https_/domain.com`
    final resizeConfig = cleanedUp[1];
    final importantParts = cleanedUp.skip(5).toList();
    final lastPart = importantParts.removeLast();
    cleanedUp = [...importantParts, resizeConfig, lastPart];
  }

  return cleanedUp;
}
