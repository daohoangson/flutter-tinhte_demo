import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_api/user.dart';

import '../api.dart';
import 'posts.dart';

class PostEditor extends StatefulWidget {
  final VoidCallback onDismissed;
  final Post parentPost;
  final Post post;
  final Thread thread;

  PostEditor(
    this.thread, {
    Key key,
    this.onDismissed,
    this.parentPost,
    this.post,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _PostEditorState(post?.postBodyPlainText);
}

class _PostEditorState extends State<PostEditor> {
  final formKey = GlobalKey<FormState>();

  bool _isPosting = false;
  String _postBody;
  VoidCallback _removeListener;
  User _user;

  _PostEditorState(this._postBody);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = ApiInheritedWidget.of(context).addApiUserListener(
        (newToken, newUser) => setState(() => _user = newUser));
  }

  @override
  void deactivate() {
    if (_removeListener != null) {
      _removeListener();
      _removeListener = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: buildRow(
          context,
          buildPosterCircleAvatar(
            _user?.links?.avatar,
            isPostReply: widget.parentPost != null,
          ),
          box: <Widget>[
            buildPosterInfo(context, _user?.username ?? ''),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your message to post',
                ),
                initialValue: _postBody,
                maxLines: 3,
                onSaved: (value) => _postBody = value,
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize:
                          DefaultTextStyle.of(context).style.fontSize - 1.0,
                    ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                buildButton(context, 'Cancel',
                    color: Theme.of(context).highlightColor,
                    onTap: _actionCancel),
                _isPosting
                    ? CircularProgressIndicator()
                    : buildButton(context, 'Post', onTap: _actionPost),
              ],
            ),
          ],
        ),
      );

  void _actionCancel() {
    _dismiss();
  }

  void _actionPost() {
    final form = formKey.currentState;
    if (!form.validate()) return;
    form.save();

    prepareForApiAction(this, () {
      if (_isPosting) return;
      setState(() => _isPosting = true);

      apiPost(this, 'posts',
          bodyFields: {
            'thread_id': widget.thread.threadId.toString(),
            'quote_post_id': widget.parentPost?.postId?.toString() ?? '',
            'post_body': _postBody,
          },
          onSuccess: (jsonMap) {
            if (jsonMap.containsKey('post')) {
              final post = Post.fromJson(jsonMap['post']);
              _dismiss(post: post);
            }
          },
          onError: (e) => showApiErrorDialog(context, e, title: 'Post error'),
          onComplete: () => setState(() => _isPosting = false));
    });
  }

  void _dismiss({Post post}) {
    if (post != null) {
      PostListInheritedWidget.of(context)?.notifyListeners(post);
    }

    if (widget.onDismissed != null) {
      widget.onDismissed();
    }
  }
}
