part of '../posts.dart';

const _kPopupActionDelete = 'delete';
const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionReport = 'report';

class _PostActionsWidget extends StatefulWidget {
  final bool showPostCreateDate;

  _PostActionsWidget({
    Key key,
    this.showPostCreateDate = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool _isLiking = false;

  @override
  Widget build(BuildContext context) => Consumer<ActionablePost>(
        builder: (context, ap, _) {
          final post = ap.post;
          final postIsDeleted = post.postIsDeleted == true;
          final postIsLiked = post.postIsLiked == true;

          final buttons = <Widget>[];

          if (!postIsDeleted) {
            if (post.links?.likes?.isNotEmpty == true) {
              buttons.add(buildPostButton(
                context,
                postIsLiked ? 'Unlike' : 'Like',
                count: post.postLikeCount,
                onTap: _isLiking
                    ? null
                    : () => (postIsLiked ? _unlikePost(ap) : _likePost(ap)),
              ));
            }

            buttons.add(buildPostButton(
              context,
              'Reply',
              onTap: () => Provider.of<PostEditorData>(context).enable(
                context,
                parentPost: Provider.of<Post>(context),
              ),
            ));
          }

          if (widget.showPostCreateDate) {
            buttons.add(buildPostButton(
              context,
              formatTimestamp(post.postCreateDate),
            ));
          }

          buttons.add(
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildPopupMenu(context, ap),
              ),
            ),
          );

          final row = Padding(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buttons,
            ),
            padding: const EdgeInsets.only(left: kPaddingHorizontal / 2),
          );

          return row;
        },
      );

  Widget _buildPopupMenu(BuildContext context, ActionablePost ap) {
    return PopupMenuButton<String>(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingHorizontal),
        child: Text(
          '•••',
          style: TextStyle(
            color: Theme.of(context).disabledColor,
            fontSize: 9,
          ),
        ),
      ),
      itemBuilder: (_) => _buildPopupMenuItems(ap),
      onSelected: (action) async {
        final post = ap.post;
        switch (action) {
          case _kPopupActionDelete:
            final reason = await showDialog(
              context: context,
              builder: (context) => _PostActionsDialogReason(
                button: 'Delete',
                hint: 'Reason to delete post.',
              ),
            );
            if (reason != null) _deletePost(ap, reason);
            break;
          case _kPopupActionOpenInBrowser:
            launch(post.links?.permalink);
            break;
          case _kPopupActionReport:
            final message = await showDialog(
              context: context,
              builder: (context) => _PostActionsDialogReason(
                button: 'Report',
                hint: 'Problem to be reported.',
              ),
            );
            if (message != null) _reportPost(ap, message);
            break;
        }
      },
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(ActionablePost ap) {
    final post = ap.post;

    final entries = <PopupMenuEntry<String>>[
      PopupMenuItem(
        child: Text('Open in browser'),
        value: _kPopupActionOpenInBrowser,
      ),
    ];

    if (post.links?.report?.isNotEmpty == true) {
      entries.add(PopupMenuItem(
        child: Text('Report'),
        enabled: post.permissions?.report == true,
        value: _kPopupActionReport,
      ));
    }

    if (post.permissions?.delete == true) {
      entries.add(PopupMenuItem(
        child: Text('Delete'),
        value: _kPopupActionDelete,
      ));
    }

    return entries;
  }

  void _deletePost(ActionablePost ap, String reason) => apiDelete(
        ApiCaller.stateful(this),
        ap.post.links.detail,
        bodyFields: {'reason': reason},
        onSuccess: (_) => ap.setIsDeleted(),
      );

  void _likePost(ActionablePost ap) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiPost(
          ApiCaller.stateful(this),
          ap.post.links.likes,
          onSuccess: (_) => ap.setIsLiked(true),
          onComplete: () => setState(() => _isLiking = false),
        );
      });

  void _reportPost(ActionablePost ap, String message) => prepareForApiAction(
        context,
        () => apiPost(
          ApiCaller.stateful(this),
          ap.post.links.report,
          bodyFields: {'message': message},
          onSuccess: (_) => Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('Thank you for your report!')),
          ),
        ),
      );

  void _unlikePost(ActionablePost ap) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiDelete(
          ApiCaller.stateful(this),
          ap.post.links.likes,
          onSuccess: (_) => ap.setIsLiked(false),
          onComplete: () => setState(() => _isLiking = false),
        );
      });
}

class _PostActionsDialogReason extends StatelessWidget {
  final String button;
  final String hint;

  final _controller = TextEditingController();

  _PostActionsDialogReason({this.button, this.hint, Key key})
      : assert(button != null),
        super(key: key);

  @override
  Widget build(BuildContext context) => AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text(button),
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
        content: TextFormField(
          autofocus: true,
          controller: _controller,
          decoration: InputDecoration(
            hintText: hint,
          ),
        ),
      );
}

class ActionablePost extends ChangeNotifier {
  final Post post;

  ActionablePost(this.post);

  void setIsDeleted() {
    post.postIsDeleted = true;
    post.permissions = null;
    notifyListeners();
  }

  void setIsLiked(bool value) {
    post.postIsLiked = value;
    post.postLikeCount ??= 0;

    if (value) {
      post.postLikeCount++;
    } else if (post.postLikeCount > 0) {
      post.postLikeCount--;
    }

    notifyListeners();
  }

  static MultiProvider buildMultiProvider(Post post, Widget child) =>
      MultiProvider(providers: [
        Provider<Post>.value(value: post),
        ChangeNotifierProvider<ActionablePost>.value(
          value: ActionablePost(post),
        ),
      ], child: child);
}
