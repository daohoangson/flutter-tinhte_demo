import 'dart:async';
import 'package:test/test.dart';
import 'package:the_api/api.dart';
import 'package:the_api/post.dart';

Future<Post> _getPostById(Api api, int postId) async {
  final json = await api.getJson("posts/$postId");
  return Post.fromJson(json['post']);
}

void main() {
  group('batch', () {
    late Api api;
    setUp(() => api = new Api('https://xfrocks.com/api/index.php', '', ''));
    tearDown(() => api.close());

    test('does nothing if no fetches', () async {
      final requestCountBefore = api.requestCount;
      final batch = api.newBatch();
      final fetched = await batch.fetch();
      expect(fetched, equals(false));
      expect(api.requestCount, equals(requestCountBefore));
    });

    test('sends all requests at once', () async {
      final requestCountBefore = api.requestCount;
      final batch = api.newBatch();
      _getPostById(api, 4)
          .then(expectAsync1((Post post) => expect(post.postId, equals(4))));
      _getPostById(api, 5)
          .then(expectAsync1((Post post) => expect(post.postId, equals(5))));
      final fetched = await batch.fetch();
      expect(fetched, equals(true));
      expect(api.requestCount - requestCountBefore, equals(1));
    });
  });
}
