import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:the_api/attachment.dart';
import 'package:the_api/post.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/widgets/font_control.dart';
import 'package:the_app/src/widgets/tinhte/background_post.dart';
import 'package:the_app/src/widgets/tinhte/tinhte_fact.dart';
import 'package:the_app/src/widgets/poll.dart';
import 'package:the_app/src/widgets/post_editor.dart';
import 'package:the_app/src/widgets/html.dart';
import 'package:the_app/src/widgets/image.dart';
import 'package:the_app/src/widgets/super_list.dart';
import 'package:the_app/src/widgets/threads.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/constants.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/link.dart';
import 'package:url_launcher/url_launcher.dart';

part 'post/actions.dart';
part 'post/attachments.dart';
part 'post/body.dart';
part 'post/builders.dart';
part 'post/first.dart';
part 'post/list.dart';
part 'post/replies.dart';

List<_PostListItem> decodePostsAndTheirReplies(List jsonPosts,
    {int parentPostId}) {
  final items = <_PostListItem>[];
  final postReplyItemById = Map<int, _PostListItem>();

  jsonPosts.forEach((jsonPost) {
    final Map<String, dynamic> map = jsonPost;
    final post = Post.fromJson(map);
    final postReplies = post.postReplies?.map((postReply) {
      final item = _PostListItem.postReply(postReply);
      postReplyItemById[postReply.postId] = item;
      return item;
    });

    if (post.postReplyTo == parentPostId) {
      items.add(_PostListItem.post(post));
      if (postReplies != null) items.addAll(postReplies);
      return;
    }

    if (post.postReplyTo == null) {
      print("Unexpected root post #${post.postId}");
      return;
    }

    if (!postReplyItemById.containsKey(post.postId)) {
      print("Unexpected reply-to post #${post.postId}");
      return;
    }

    final postReplyItem = postReplyItemById[post.postId];
    postReplyItem.post = post;

    if (postReplies != null) {
      final index = items.indexOf(postReplyItem);
      assert(index != -1);
      items.insertAll(index + 1, postReplies);
    }
  });

  return items;
}
