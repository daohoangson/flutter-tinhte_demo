part of '../posts.dart';

const _kPopupActionDelete = 'delete';
const _kPopupActionOpenInBrowser = 'openInBrowser';
const _kPopupActionReport = 'report';

class _PostActionsWidget extends StatefulWidget {
  final Post post;
  final bool showPostCreateDate;

  _PostActionsWidget({
    Key? key,
    required this.post,
    this.showPostCreateDate = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PostActionsWidgetState();
}

class _PostActionsWidgetState extends State<_PostActionsWidget> {
  bool _isLiking = false;

  Post get post => widget.post;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: post,
        builder: (context, _) {
          final buttons = <Widget>[];

          if (!post.postIsDeleted) {
            if (post.links?.likes?.isNotEmpty == true) {
              buttons.add(buildPostButton(
                context,
                post.postIsLiked ? l(context).postUnlike : l(context).postLike,
                count: post.postLikeCount ?? 0,
                onTap: _isLiking
                    ? null
                    : () => (post.postIsLiked
                        ? _unlikePost(post)
                        : _likePost(post)),
              ));
            }

            buttons.add(buildPostButton(
              context,
              l(context).postReply,
              onTap: () => context.read<PostEditorData>().enable(
                    context,
                    parentPost: post,
                  ),
            ));
          }

          if (widget.showPostCreateDate) {
            buttons.add(buildPostButton(
              context,
              formatTimestamp(context, post.postCreateDate),
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

  Widget _buildPopupMenu(BuildContext context, Post post) {
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
            final permalink = post.links?.permalink;
            if (permalink != null) {
              launchLink(context, permalink, forceWebView: true);
            }
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

  List<PopupMenuEntry<String>> _buildPopupMenuItems(Post post) {
    final entries = <PopupMenuEntry<String>>[
      if (post.links?.permalink != null)
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

  void _deletePost(Post post, String reason) => apiDelete(
        ApiCaller.stateful(this),
        post.links?.detail ?? '',
        bodyFields: {'reason': reason},
        onSuccess: (_) => post.postIsDeleted = true,
      );

  void _likePost(Post post) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiPost(
          ApiCaller.stateful(this),
          post.links?.likes ?? '',
          onSuccess: (_) => post.postIsLiked = true,
          onComplete: () => setState(() => _isLiking = false),
        );
      });

  void _reportPost(Post post, String message) => prepareForApiAction(
        context,
        () => apiPost(
          ApiCaller.stateful(this),
          post.links?.report ?? '',
          bodyFields: {'message': message},
          onSuccess: (_) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l(context).postReportedThanks)),
          ),
        ),
      );

  void _unlikePost(Post post) => prepareForApiAction(context, () {
        if (_isLiking) return;
        setState(() => _isLiking = true);

        apiDelete(
          ApiCaller.stateful(this),
          post.links?.likes ?? '',
          onSuccess: (_) => post.postIsLiked = false,
          onComplete: () => setState(() => _isLiking = false),
        );
      });
}

class _PostActionsDialogReason extends StatelessWidget {
  final String button;
  final String hint;

  final _controller = TextEditingController();

  _PostActionsDialogReason({required this.button, required this.hint, Key? key})
      : super(key: key);

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
