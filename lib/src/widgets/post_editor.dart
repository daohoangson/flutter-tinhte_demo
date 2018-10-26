import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';

import '../api.dart';
import 'attachment_editor.dart';
import 'html.dart';
import 'posts.dart';

class PostEditor extends StatefulWidget {
  final int parentPostId;
  final Post post;
  final int threadId;

  PostEditor(
    this.threadId, {
    Key key,
    this.parentPostId,
    this.post,
  })  : assert(threadId != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _PostEditorState(post?.postBodyPlainText ?? '');
}

class _PostEditorState extends State<PostEditor> {
  final formKey = GlobalKey<FormState>();

  String _attachmentHash;
  bool _isPosting = false;
  String _postBody;

  _PostEditorState(this._postBody);

  @override
  Widget build(BuildContext context) {
    final user = ApiData.of(context).user;

    return Form(
      key: formKey,
      child: buildRow(
        context,
        buildPosterCircleAvatar(
          user?.links?.avatar,
          isPostReply: widget.parentPostId != null,
        ),
        box: <Widget>[
          buildPosterInfo(context, user?.username ?? ''),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your message to post',
              ),
              initialValue: _postBody,
              maxLines: 3,
              onSaved: (value) => _postBody = value,
              style: getPostBodyTextStyle(context, false),
              validator: (message) {
                if (message.isEmpty) {
                  return 'Please enter some text.';
                }

                return null;
              },
            ),
          ),
        ],
        footer: <Widget>[
          _attachmentHash != null
              ? AttachmentEditor(
                  "posts/attachments?thread_id=${widget.threadId}",
                  _attachmentHash,
                )
              : null,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _attachmentHash == null
                  ? buildButton(
                      context,
                      'Upload images',
                      onTap: () => setState(() =>
                          _attachmentHash = "${Random.secure().nextDouble()}"),
                    )
                  : Container(height: 0.0, width: 0.0),
              buildButton(
                context,
                'Post',
                onTap: _isPosting ? null : _post,
              ),
            ],
          ),
        ],
      ),
    );
  }

  _post() {
    final form = formKey.currentState;
    if (!form.validate()) return;
    form.save();

    prepareForApiAction(this, () {
      if (_isPosting) return;
      setState(() => _isPosting = true);

      apiPost(this, 'posts',
          bodyFields: {
            'attachment_hash': _attachmentHash ?? '',
            'post_body': _postBody,
            'quote_post_id': widget.parentPostId?.toString() ?? '',
            'thread_id': widget.threadId.toString(),
          },
          onSuccess: (jsonMap) {
            if (jsonMap.containsKey('post')) {
              final post = Post.fromJson(jsonMap['post']);
              PostListInheritedWidget.of(context)?.notifyListeners(post);
            }
          },
          onError: (e) => showApiErrorDialog(context, e, title: 'Post error'),
          onComplete: () => setState(() => _isPosting = false));
    });
  }
}
