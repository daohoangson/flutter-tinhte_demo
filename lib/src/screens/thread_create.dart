import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/thread.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/intl.dart';
import 'package:tinhte_demo/src/screens/thread_view.dart';
import 'package:tinhte_demo/src/widgets/attachment_editor.dart';
import 'package:tinhte_demo/src/widgets/forum/forum_picker.dart';

class ThreadCreateScreen extends StatefulWidget {
  @override
  _ThreadCreateScreenState createState() => _ThreadCreateScreenState();
}

class _ThreadCreateScreenState extends State<ThreadCreateScreen> {
  final aesKey = GlobalKey<AttachmentEditorState>();
  final formKey = GlobalKey<FormState>();

  ForumPickerData fpd;
  _ThreadCreateData tcd;

  @override
  void initState() {
    super.initState();
    fpd = ForumPickerData();
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
  Widget build(BuildContext context) => MultiProvider(
        child: Scaffold(
          appBar: AppBar(
            title: Text(l(context).threadCreateNew),
            actions: <Widget>[
              Consumer2<ForumPickerData, _ThreadCreateData>(
                builder: (_, fpd, tcd, __) => IconButton(
                  icon: Icon(FontAwesomeIcons.paperPlane),
                  onPressed: fpd.forum != null && tcd._isPosting == false
                      ? _post
                      : null,
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

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      );

  void _onForumPickerData() {
    final forum = fpd.forum;
    if (forum == null) return;

    aesKey.currentState
        ?.setPath('threads/attachments?forum_id=${forum.forumId}');
  }

  void _post() {
    if (tcd._isPosting) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    prepareForApiAction(context, () {
      if (tcd._isPosting) return;
      tcd.isPosting = true;

      apiPost(
        ApiCaller.stateful(this),
        'threads',
        bodyFields: {
          'attachment_hash': aesKey.currentState?.attachmentHash ?? '',
          'forum_id': '${fpd.forum.forumId}',
          'post_body': tcd._body,
          'thread_title': tcd._title,
        },
        onSuccess: (jsonMap) {
          if (!jsonMap.containsKey('thread')) return;
          final thread = Thread.fromJson(jsonMap['thread']);
          if (thread.threadId == null) return;
          Navigator.of(context)
            ..pop()
            ..push(MaterialPageRoute(builder: (_) => ThreadViewScreen(thread)));
        },
        onError: (e) =>
            showApiErrorDialog(context, e, title: l(context).threadCreateError),
        onComplete: () => tcd.isPosting = false,
      );
    });
  }
}

class _ThreadCreateData extends ChangeNotifier {
  String _body;
  bool _isPosting = false;
  String _title;

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
}

class _ThreadCreateTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).threadCreateTitleHint,
        labelText: l(context).threadCreateTitle,
      ),
      onSaved: (v) => context.read<_ThreadCreateData>().title = v,
      validator: (title) {
        if (title.isEmpty) {
          return l(context).threadCreateErrorTitleIsEmpty;
        }

        return null;
      });
}

class _ThreadCreateBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).threadCreateBodyHint,
        labelText: l(context).threadCreateBody,
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onSaved: (v) => context.read<_ThreadCreateData>().body = v,
      validator: (body) {
        if (body.isEmpty) {
          return l(context).threadCreateErrorBodyIsEmpty;
        }

        return null;
      });
}
