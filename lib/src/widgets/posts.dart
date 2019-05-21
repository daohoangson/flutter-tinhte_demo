import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinhte_api/attachment.dart';
import 'package:tinhte_api/node.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../screens/forum_view.dart';
import '../api.dart';
import '../config.dart';
import '../constants.dart';
import '../intl.dart';
import '../link.dart';
import 'html.dart';
import 'image.dart';
import 'post_editor.dart';
import 'super_list.dart';

part 'post/actions.dart';
part 'post/attachments.dart';
part 'post/builders.dart';
part 'post/first.dart';
part 'post/inherited_widgets.dart';
part 'post/list.dart';
part 'post/replies.dart';

class PostsWidget extends StatelessWidget {
  final Map initialJson;
  final String path;
  final Thread thread;

  PostsWidget({
    this.initialJson,
    Key key,
    this.path,
    this.thread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _ThreadInheritedWidget(
        thread: thread,
        child: PostListInheritedWidget(
          child: _PostListWidget(
            thread,
            initialJson: initialJson,
            path: path,
          ),
        ),
      );
}
