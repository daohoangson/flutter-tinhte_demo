import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:test/test.dart';
import 'package:the_api/api.dart';

void main() {
  group('http', () {
    final httpClient = http.MockClient(
      (request) async => http.Response(
        jsonEncode({
          'method': request.method,
          'url': request.url.toString(),
        }),
        200,
      ),
    );
    final api = Api(httpClient, apiRoot: '');

    test('deletes ok', () async {
      const url = 'http://domain.com/delete';
      final json = await api.deleteJson(url);
      expect(json['method'], equals('DELETE'));
      expect(json['url'], equals(url));
    });

    test('gets ok', () async {
      const url = 'http://domain.com/get';
      final json = await api.getJson(url);
      expect(json['method'], equals('GET'));
      expect(json['url'], equals(url));
    });

    test('posts ok', () async {
      const url = 'http://domain.com/post';
      final json = await api.postJson(url);
      expect(json['method'], equals('POST'));
      expect(json['url'], equals(url));
    });

    test('puts ok', () async {
      const url = 'http://domain.com/put';
      final json = await api.putJson(url);
      expect(json['method'], equals('PUT'));
      expect(json['url'], equals(url));
    });
  });
}
