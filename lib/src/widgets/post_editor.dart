import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';

import '../api.dart';
import 'attachment_editor.dart';
import 'posts.dart';

class PostEditorWidget extends StatefulWidget {
  final PostEditorCallback callback;

  PostEditorWidget({this.callback}) : assert(callback != null);

  @override
  State<StatefulWidget> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditorWidget> {
  final _controller = TextEditingController();

  String _sessionId;
  bool _isPosting = false;

  _PostEditorState();

  @override
  Widget build(BuildContext _) =>
      Consumer<PostEditorData>(builder: (context, data, __) {
        if (data.sessionId != _sessionId) {
          _sessionId = data.sessionId;
          _controller.text = '';
        }

        return Column(
          children: <Widget>[
            _buildIntro(data),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(kPaddingHorizontal),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: kPaddingHorizontal),
                child: data._isEnabled
                    ? _buildInputs(data)
                    : _buildPlaceholder(data),
              ),
            ),
            AttachmentEditorWidget(key: data._aesKey),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        );
      });

  Widget _buildInputs(PostEditorData data) => Row(
        children: <Widget>[
          Expanded(child: _buildTextInputMessage(focusNode: data._focusNode)),
          InkWell(
            child: Icon(Icons.image),
            onTap: () => data._aesKey.currentState?.pickGallery(),
          ),
          InkWell(
            child: Padding(
              child: Icon(Icons.done),
              padding: const EdgeInsets.symmetric(
                vertical: kPaddingHorizontal,
                horizontal: kPaddingHorizontal,
              ),
            ),
            onTap: _isPosting ? null : () => _post(data),
          )
        ],
      );

  Widget _buildIntro(PostEditorData data) {
    final parentPost = data._parentPost;
    if (parentPost?.postIsFirstPost != false) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Padding(
      child: RichText(
        text: TextSpan(
          text: 'Replying to @',
          style: textTheme.body1,
          children: [
            TextSpan(
              text: parentPost.posterUsername + ' ',
              style: textTheme.body1.copyWith(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: parentPost.postBodyPlainText.replaceAll('\n', ' '),
              style: textTheme.caption,
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      padding: const EdgeInsets.only(bottom: kPaddingHorizontal / 2),
    );
  }

  Widget _buildPlaceholder(PostEditorData data) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: _buildTextInputMessage(),
        onTap: () => data.enable(context),
      );

  Widget _buildTextInputMessage({FocusNode focusNode}) => TextFormField(
        controller: focusNode != null ? _controller : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter your message to post',
        ),
        enabled: focusNode != null,
        focusNode: focusNode,
        key: focusNode != null ? ValueKey(focusNode.hashCode) : null,
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        minLines: 1,
        style: getPostBodyTextStyle(context, false),
        textCapitalization: TextCapitalization.sentences,
      );

  void _post(PostEditorData data) {
    if (data.sessionId != _sessionId) return;
    final attachmentHash = data._aesKey.currentState?.attachmentHash ?? '';
    final parentPost = data._parentPost;
    final quotePostId = parentPost?.postIsFirstPost != false
        ? ''
        : parentPost?.postId?.toString() ?? '';
    final text = _controller.text.trim();
    final threadId = data.thread.threadId.toString();
    if (text.isEmpty) {
      data._disable(context);
      return;
    }

    prepareForApiAction(context, () {
      if (_isPosting) return;
      setState(() => _isPosting = true);

      apiPost(
        ApiCaller.stateful(this),
        'posts',
        bodyFields: {
          'attachment_hash': attachmentHash,
          'post_body': text,
          'quote_post_id': quotePostId,
          'thread_id': threadId,
        },
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('post')) return;
          widget.callback(Post.fromJson(jsonMap['post']));
          data._disable(context);
        },
        onError: (e) => showApiErrorDialog(context, e, title: 'Post error'),
        onComplete: () => setState(() => _isPosting = false),
      );
    });
  }
}

typedef void PostEditorCallback(Post post);

class PostEditorData extends ChangeNotifier {
  final Thread thread;

  final _focusNode = FocusNode();
  final _aesKey = GlobalKey<AttachmentEditorState>();

  var _counter = 0;
  var _isEnabled = false;
  Post _parentPost;

  PostEditorData(this.thread) : assert(thread != null);

  String get sessionId => "$hashCode-$_counter";

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  void enable(BuildContext context, {Post parentPost}) {
    _parentPost = parentPost;

    _counter++;
    _aesKey.currentState
        ?.setPath("posts/attachments?thread_id=${thread.threadId}");

    _isEnabled = true;
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback(
        (_) => FocusScope.of(context).requestFocus(_focusNode));
  }

  void _disable(BuildContext context) {
    _counter++;
    _parentPost = null;
    _aesKey.currentState?.setPath();

    _isEnabled = false;
    notifyListeners();

    FocusScope.of(context).requestFocus(new FocusNode());
  }
}
