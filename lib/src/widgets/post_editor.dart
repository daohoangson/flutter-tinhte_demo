import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/post.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/widgets/attachment_editor.dart';
import 'package:tinhte_demo/src/widgets/posts.dart';
import 'package:tinhte_demo/src/data/emojis.dart';
import 'package:tinhte_demo/src/api.dart';

class PostEditorWidget extends StatefulWidget {
  final PostEditorCallback callback;
  final double paddingHorizontal;
  final double paddingVertical;

  PostEditorWidget({
    this.callback,
    this.paddingHorizontal,
    this.paddingVertical,
  }) : assert(callback != null);

  @override
  State<StatefulWidget> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditorWidget> {
  final _controller = TextEditingController();

  _EmojiSuggestion _emojiSuggestion;
  Timer _emojiTimer;

  String _sessionId;
  bool _isPosting = false;

  _PostEditorState();

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    super.dispose();

    _controller.removeListener(_onTextChange);
    _controller.dispose();

    _emojiTimer?.cancel();
  }

  @override
  Widget build(BuildContext _) =>
      Consumer<PostEditorData>(builder: (context, data, __) {
        if (data.sessionId != _sessionId) {
          _sessionId = data.sessionId;
          _controller.text = '';
        }

        return Padding(
          child: Column(
            children: <Widget>[
              _emojiSuggestion != null
                  ? _buildEmojiSuggestion(_emojiSuggestion)
                  : SizedBox(height: widget.paddingVertical),
              _buildIntro(data),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                  borderRadius: BorderRadius.circular(widget.paddingHorizontal),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: widget.paddingHorizontal),
                  child: data._isEnabled
                      ? _buildInputs(data)
                      : _buildPlaceholder(data),
                ),
              ),
              AttachmentEditorWidget(key: data._aesKey),
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
          padding: EdgeInsets.fromLTRB(
            widget.paddingHorizontal,
            0,
            widget.paddingHorizontal,
            widget.paddingVertical,
          ),
        );
      });

  Widget _buildEmojiSuggestion(_EmojiSuggestion es) => SingleChildScrollView(
        child: Row(
          children: es.emojis.entries
              .map<Widget>((entry) => InkWell(
                    child: Tooltip(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        child: Text(entry.key, textScaleFactor: 2),
                      ),
                      message: entry.value,
                    ),
                    onTap: () {
                      setState(() => _emojiSuggestion = null);

                      final text = _controller.text;
                      if (text.substring(es.start, es.end) != es.query) return;

                      final replacement =
                          entry.key + (es.end == text.length ? ' ' : '');
                      _controller.value = TextEditingValue(
                        text: text.replaceRange(es.start, es.end, replacement),
                        selection: TextSelection.collapsed(
                            offset: es.start + replacement.length),
                      );
                    },
                  ))
              .toList(growable: false),
        ),
        scrollDirection: Axis.horizontal,
      );

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
          style: textTheme.bodyText2,
          children: [
            TextSpan(
              text: parentPost.posterUsername + ' ',
              style: textTheme.bodyText2.copyWith(
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

  void _onTextChange() {
    if (_emojiTimer != null) _emojiTimer.cancel();
    _emojiTimer = Timer(const Duration(milliseconds: 500), _suggestEmoji);
  }

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

  void _suggestEmoji() => setState(() => _emojiSuggestion =
      _EmojiSuggestion.suggest(_controller.text, _controller.selection));
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

    final focus = FocusScope.of(context);
    if (!focus.hasPrimaryFocus) {
      focus.unfocus();
    }
  }
}

class _EmojiSuggestion {
  final String query;
  final Map<String, String> emojis;
  final int start;
  final int end;

  static final _regExpBefore = RegExp(r':[a-z]+(:?)$', caseSensitive: false);
  static final _regExpAfter = RegExp(r'^[a-z]*:?', caseSensitive: false);

  _EmojiSuggestion({this.query, this.emojis, this.start})
      : assert(query != null),
        assert(emojis != null),
        assert(start != null),
        end = start + query.length;

  factory _EmojiSuggestion.suggest(String text, TextSelection s) {
    if (!s.isValid) return null;

    // get text right before and after carret that is
    // starting and ending with double colon `:`
    final before = _regExpBefore.firstMatch(s.textBefore(text));
    if (before == null) return null;
    final after = before.group(1) != null
        ? _regExpAfter.matchAsPrefix(s.textAfter(text))
        : null;

    // skip suggestion if query is not long enough (avoid rendering too many results)
    final query =
        (before.group(0) + (after != null ? after.group(0) : '')).toLowerCase();
    if (query.length < 3) return null;

    final emojis = searchEmojis(query);
    if (emojis == null) return null;

    return _EmojiSuggestion(
      query: query,
      emojis: emojis,
      start: s.end - before.group(0).length,
    );
  }
}
