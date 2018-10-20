import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/links.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../intl.dart';
import '_api.dart';
import 'html.dart';
import 'post_editor.dart';

part 'post/actions.dart';
part 'post/builders.dart';
part 'post/inherited_widgets.dart';
part 'post/list.dart';
part 'post/replies.dart';

class PostsWidget extends StatelessWidget {
  final String path;
  final Thread thread;

  PostsWidget({
    Key key,
    @required this.path,
    this.thread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _ThreadInheritedWidget(
        thread: thread,
        child: PostListInheritedWidget(
          child: _PostListWidget(thread, path: path),
        ),
      );
}
