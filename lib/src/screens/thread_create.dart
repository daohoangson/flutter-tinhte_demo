import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_api/node.dart';
import 'package:the_api/thread.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/thread_view.dart';
import 'package:the_app/src/widgets/attachment_editor.dart';
import 'package:the_app/src/widgets/forum/forum_picker.dart';

class ThreadCreateScreen extends StatefulWidget {
  final Forum forum;

  const ThreadCreateScreen({Key key, this.forum}) : super(key: key);

  @override
  _ThreadCreateScreenState createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends State<ThreadCreateScreen> {
  final aesKey = GlobalKey<AttachmentEditorState>();
  final formKey = GlobalKey<FormState>();

  /* late final */ ForumPickerData fpd;
  /* late final */ _ThreadCreateData tcd;

  @override
  void initState() {
    super.initState();

    fpd = ForumPickerData(widget.forum);
    tcd = _ThreadCreateData();

    fpd.addListener(_onForumPickerData);
  }

  @override
  void dispose() {
    fpd.dispose();
    tcd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forum = widget.forum;

    return MultiProvider(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l(context).threadCreateNew),
          actions: <Widget>[
            Consumer2<ForumPickerData, _ThreadCreateData>(
              builder: (_, fpd, tcd, __) => IconButton(
                icon: Icon(FontAwesomeIcons.paperPlane),
                onPressed:
                    fpd.forum != null && tcd._isPosting == false ? _post : null,
                tooltip: l(context).threadCreateSubmit,
              ),
            ),
          ],
        ),
        body: Form(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    ForumPickerWidget(),
                    _buildInputPadding(_ThreadCreateTitle()),
                    _buildInputPadding(_ThreadCreateBody()),
                  ],
                ),
              ),
              AttachmentEditorWidget(
                apiPostPath:
                    forum != null ? _generateAttachmentPath(forum) : null,
                height: 150,
                key: aesKey,
                showPickIcon: true,
              ),
            ],
          ),
          key: formKey,
        ),
      ),
      providers: [
        ChangeNotifierProvider<ForumPickerData>.value(value: fpd),
        ChangeNotifierProvider<_ThreadCreateData>.value(value: tcd),
      ],
    );
  }

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      );

  void _onForumPickerData() {
    final forum = fpd.forum;
    if (forum == null) return;

    aesKey.currentState?.setPath(_generateAttachmentPath(forum));
  }

  void _post() {
    if (tcd._isPosting) return;

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    final forum = fpd.forum;
    if (forum == null) return;

    prepareForApiAction(context, () {
      if (tcd._isPosting) return;
      tcd.isPosting = true;

      apiPost(
        ApiCaller.stateful(this),
        'threads',
        bodyFields: {
          'attachment_hash': aesKey.currentState?.attachmentHash ?? '',
          'forum_id': '${forum.forumId}',
          'post_body': tcd._body,
          'thread_title': tcd._title,
        },
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('thread')) return;
          final thread = Thread.fromJson(jsonMap['thread']);
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)));
        },
        onError: (e) =>
            showApiErrorDialog(context, e, title: l(context).threadCreateError),
        onComplete: () => tcd.isPosting = false,
      );
    });
  }

  static String _generateAttachmentPath(Forum forum) =>
      'threads/attachments?forum_id=${forum.forumId}';
}

class _ThreadCreateData extends ChangeNotifier {
  final focusNodeBody = FocusNode();

  String /*!*/ _body = '';
  bool _isPosting = false;
  String /*!*/ _title = '';

  set body(String v) {
    _body = v;
    notifyListeners();
  }

  set isPosting(bool v) {
    _isPosting = v;
    notifyListeners();
  }

  set title(String v) {
    _title = v;
    notifyListeners();
  }

  @override
  void dispose() {
    focusNodeBody.dispose();
    super.dispose();
  }
}

class _ThreadCreateTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<_ThreadCreateData>();

    return TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).threadCreateTitleHint,
        labelText: l(context).threadCreateTitle,
      ),
      onEditingComplete: () =>
          context.read<_ThreadCreateData>().focusNodeBody.requestFocus(),
      onSaved: (v) => data.title = v,
      validator: (value) {
        final title = (value ?? '').trim();
        if (title.isEmpty) {
          return l(context).threadCreateErrorTitleIsEmpty;
        }

        return null;
      },
    );
  }
}

class _ThreadCreateBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<_ThreadCreateData>();

    return TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).threadCreateBodyHint,
        labelText: l(context).threadCreateBody,
      ),
      focusNode: data.focusNodeBody,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onEditingComplete: () => data,
      onSaved: (v) => data.body = v,
      validator: (value) {
        final body = (value ?? '').trim();
        if (body.isEmpty) {
          return l(context).threadCreateErrorBodyIsEmpty;
        }

        return null;
      },
    );
  }
}
