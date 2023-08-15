import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:the_api/post.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/widgets/tinhte/background_post.dart';

import '../../../test_utils.dart';

void main() {
  group('BackgroundPost', () {
    testGoldens('renders', (tester) async {
      await tester.pumpMockedApiApp(const _BackgroundPostTestApp());
      await tester.waitForStuff();

      await screenMatchesGolden(tester, 'background_post');
    });
  });
}

class _BackgroundPostTestApp extends StatelessWidget {
  const _BackgroundPostTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SuperListView<Post>(
          fetchPathInitial: 'posts&thread_id=3072651',
          fetchOnSuccess: _fetchOnSuccess,
          itemBuilder: (_, __, post) => BackgroundPost(post),
        ),
      );

  void _fetchOnSuccess(Map json, FetchContext<Post> fc) {
    for (final postJson in (json['posts'] as List)) {
      final post = Post.fromJson(postJson);
      fc.items.add(post);
    }
  }
}
