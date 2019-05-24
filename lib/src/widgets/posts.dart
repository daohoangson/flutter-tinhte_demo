import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:tinhte_api/attachment.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../config.dart';
import '../constants.dart';
import '../intl.dart';
import '../link.dart';
import 'html.dart';
import 'image.dart';
import 'post_editor.dart';
import 'super_list.dart';
import 'threads.dart';

part 'post/actions.dart';
part 'post/attachments.dart';
part 'post/body.dart';
part 'post/builders.dart';
part 'post/first.dart';
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
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider<Thread>.value(value: thread),
          NewPostStream.buildProvider(),
        ],
        child: _PostListWidget(
          thread,
          initialJson: initialJson,
          path: path,
        ),
      );
}
