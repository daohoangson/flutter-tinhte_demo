import 'package:test/test.dart';
import 'package:the_api/api.dart';

void main() {
  group('http', () {
    Api api;
    setUp(() => api = new Api('', '', ''));
    tearDown(() => api.close());

    test('deletes ok', () async {
      final url = 'https://httpbin.org/delete';
      final json = await api.deleteJson(url);
      expect(json['url'], equals(url));
    });

    test('gets ok', () async {
      const url = 'https://httpbin.org/get';
      final json = await api.getJson(url);
      expect(json['url'], equals(url));
    });

    test('posts ok', () async {
      const url = 'https://httpbin.org/post';
      final json = await api.postJson(url);
      expect(json['url'], equals(url));
    });

    test('puts ok', () async {
      const url = 'https://httpbin.org/put';
      final json = await api.putJson(url);
      expect(json['url'], equals(url));
    });
  });
}
