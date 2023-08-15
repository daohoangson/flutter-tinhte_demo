final mocksParts = List.unmodifiable(['packages', 'api_test', 'mocks']);

Iterable<String> cleanUpParts(Iterable<String> parts) {
  return parts.map((e) => e.replaceAll(RegExp('[:]'), '_'));
}
