import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';

import '../api.dart';
import 'attachment_editor.dart';
import 'html.dart';
import 'posts.dart';

class PostEditor extends StatefulWidget {
  final PostEditorCallback callback;
  final int parentPostId;
  final Post post;
  final int threadId;

  PostEditor(
    this.threadId, {
    this.callback,
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
          buildPosterInfo(
            context,
            this,
            user?.username ?? '',
            userHasVerifiedBadge: user?.userHasVerifiedBadge,
            userRank: user?.rank?.rankName,
          ),
          Padding(
            padding: kEdgeInsetsHorizontal,
            child: TextFormField(
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your message to post',
              ),
              initialValue: _postBody,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              onSaved: (value) => _postBody = value,
              style: getPostBodyTextStyle(context, false),
              textCapitalization: TextCapitalization.sentences,
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
          Padding(
            padding: kEdgeInsetsHorizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _attachmentHash == null
                    ? buildButton(
                        context,
                        'Upload images',
                        onTap: () => setState(() => _attachmentHash =
                            "${Random.secure().nextDouble()}"),
                      )
                    : Container(height: 0.0, width: 0.0),
                buildButton(
                  context,
                  'Post',
                  onTap: _isPosting ? null : _post,
                ),
              ],
            ),
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
              if (widget.callback != null) {
                widget.callback(post);
              }
            }
          },
          onError: (e) => showApiErrorDialog(context, e, title: 'Post error'),
          onComplete: () => setState(() => _isPosting = false));
    });
  }
}

typedef void PostEditorCallback(Post post);
