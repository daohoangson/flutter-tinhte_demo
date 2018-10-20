import 'package:flutter/material.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_api/user.dart';

import '_api.dart';
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

  ApiUserListener _listener;
  bool _isPosting = false;
  String _postBody;
  User _user;

  _PostEditorState(this._postBody);

  @override
  void initState() {
    super.initState();
    _listener = (newToken, newUser) => setState(() => _user = newUser);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ApiInheritedWidget.of(context).addApiUserListener(_listener);
  }

  @override
  void deactivate() {
    ApiInheritedWidget.of(context).removeApiUserListener(_listener);
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
                buildButton(context, 'Cancel', _actionCancel,
                    color: Theme.of(context).highlightColor),
                _isPosting
                    ? CircularProgressIndicator()
                    : buildButton(context, 'Post', _actionPost),
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

    prepareForApiAction(context, (apiData) {
      if (_isPosting) return;
      setState(() => _isPosting = true);

      apiData.api
          .postJson('posts', bodyFields: {
            'thread_id': widget.thread.threadId.toString(),
            'quote_post_id': widget.parentPost?.postId?.toString() ?? '',
            'post_body': _postBody,
          })
          .then((json) {
            if (json is Map && json.containsKey('post')) {
              final post = Post.fromJson(json['post']);
              _dismiss(post: post);
            }
          })
          .catchError((e) => showApiErrorDialog(context, 'Post error', e))
          .whenComplete(() => setState(() => _isPosting = false));
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
