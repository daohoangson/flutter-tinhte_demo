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
        builder: (context, post, _) {
          final buttons = <Widget>[];

          if (!post.isDeleted) {
            if (post.links?.likes?.isNotEmpty == true) {
              buttons.add(buildPostButton(
                context,
                post.isLiked ? l(context).postUnlike : l(context).postLike,
                count: post.likeCount,
                onTap: _isLiking
                    ? null
                    : () =>
                        (post.isLiked ? _unlikePost(post) : _likePost(post)),
              ));
            }

            buttons.add(buildPostButton(
              context,
              l(context).postReply,
              onTap: () => context.read<PostEditorData>().enable(
                    context,
                    parentPost: context.read<Post>(),
                  ),
            ));
          }

          if (widget.showPostCreateDate) {
            buttons.add(buildPostButton(
              context,
              formatTimestamp(context, post.createDate),
            ));
          }

          buttons.add(
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _buildPopupMenu(context, post),
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

  Widget _buildPopupMenu(BuildContext context, ActionablePost post) {
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
      itemBuilder: (_) => _buildPopupMenuItems(post),
      onSelected: (action) async {
        switch (action) {
          case _kPopupActionDelete:
            final reason = await showDialog(
              context: context,
              builder: (context) => _PostActionsDialogReason(
                button: l(context).postDelete,
                hint: l(context).postDeleteReasonHint,
              ),
            );
            if (reason != null) _deletePost(post, reason);
            break;
          case _kPopupActionOpenInBrowser:
            launchLink(context, post.links?.permalink, forceWebView: true);
            break;
          case _kPopupActionReport:
            final message = await showDialog(
              context: context,
              builder: (context) => _PostActionsDialogReason(
                button: l(context).postReport,
                hint: l(context).postReportReasonHint,
              ),
            );
            if (message != null) _reportPost(post, message);
            break;
        }
      },
    );
  }

  List<PopupMenuEntry<String>> _buildPopupMenuItems(ActionablePost post) {
    final entries = <PopupMenuEntry<String>>[
      PopupMenuItem(
        child: Text(l(context).openInBrowser),
        value: _kPopupActionOpenInBrowser,
      ),
    ];

    if (post.links?.report?.isNotEmpty == true) {
      entries.add(PopupMenuItem(
        child: Text(l(context).postReport),
        enabled: post.permissions?.report == true,
        value: _kPopupActionReport,
      ));
    }

    if (post.permissions?.delete == true) {
      entries.add(PopupMenuItem(
        child: Text(l(context).postDelete),
        value: _kPopupActionDelete,
      ));
    }

    return entries;
  }

  void _deletePost(ActionablePost post, String reason) => apiDelete(
        ApiCaller.stateful(this),
        post.links.detail,
        bodyFields: {'reason': reason},
        onSuccess: (_) => post.isDeleted = true,
      );

  void _likePost(ActionablePost post) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiPost(
          ApiCaller.stateful(this),
          post.links.likes,
          onSuccess: (_) => post.isLiked = true,
          onComplete: () => setState(() => _isLiking = false),
        );
      });

  void _reportPost(ActionablePost post, String message) => prepareForApiAction(
        context,
        () => apiPost(
          ApiCaller.stateful(this),
          post.links.report,
          bodyFields: {'message': message},
          onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l(context).postReportedThanks)),
          ),
        ),
      );

  void _unlikePost(ActionablePost post) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiDelete(
          ApiCaller.stateful(this),
          post.links.likes,
          onSuccess: (_) => post.isLiked = false,
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
          TextButton(
            child: Text(lm(context).cancelButtonLabel),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
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
