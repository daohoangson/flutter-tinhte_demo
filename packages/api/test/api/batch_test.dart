import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http;
import 'package:test/test.dart';
import 'package:the_api/api.dart';

void main() {
  group('batch', () {
    test('does nothing if no fetches', () async {
      final httpClient = http.MockClient((_) async => http.Response('', 404));
      final api = Api(httpClient, apiRoot: '');

      expect(api.requestCount, equals(0));
      final batch = api.newBatch();
      final fetched = await batch.fetch();
      expect(fetched, isFalse);
      expect(api.requestCount, equals(0));
    });

    test('handles responses', () async {
      final httpClient = http.MockClient((_) async => http.Response('''
{
  "jobs": {
    "job1": {
      "_job_result": "ok",
      "hello": "foo"
    },
    "job2": {
      "_job_error": "sorry bar"
    }
  }      
}''', 200));

      final api = Api(httpClient, apiRoot: '');
      final batch = api.newBatch();
      expect(api.requestCount, equals(0));

      api.getJson("foo").then(
          expectAsync1((json) => expect(json, containsPair("hello", "foo"))));

      expectLater(
          api.getJson("bar"),
          throwsA(isA<ApiErrorSingle>().having(
            (error) => error.message,
            'message',
            equals('sorry bar'),
          )));

      final fetched = await batch.fetch();
      expect(fetched, isTrue);
      expect(api.requestCount, equals(1));
    });

    test('handles batch error', () async {
      final httpClient = http.MockClient((_) async => http.Response('', 404));
      final api = Api(httpClient, apiRoot: '');
      final batch = api.newBatch();
      expect(api.requestCount, equals(0));

      expectLater(api.getJson("foo"), throwsA(isA<FormatException>()));
      expectLater(api.getJson("bar"), throwsA(isA<FormatException>()));

      final fetched = await batch.fetch();
      expect(fetched, isFalse);
      expect(api.requestCount, equals(1));
    });
  });
}
