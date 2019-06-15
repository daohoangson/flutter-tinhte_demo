part of '../posts.dart';

class _PostAttachmentsWidget extends StatelessWidget {
  final List<Attachment> attachments;

  _PostAttachmentsWidget(this.attachments);

  @override
  Widget build(BuildContext context) {
    final lbTrigger = LbTrigger();
    for (final attachment in attachments) {
      lbTrigger.sources.add(attachment.links.data);
    }

    return Padding(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          itemBuilder: (context, i) => lbTrigger.buildGestureDetector(
                context,
                i,
                _buildAttachment(attachments[i]),
              ),
          itemCount: attachments.length,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, i) => const SizedBox(width: 10.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    );
  }

  Widget _buildAttachment(Attachment attachment) => AspectRatio(
        aspectRatio: attachment.attachmentWidth / attachment.attachmentHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: buildCachedNetworkImage(attachment.links.thumbnail),
        ),
      );

  static Widget forPost(Post post, {Thread thread}) {
    final attachments = post.attachments?.where((attachment) {
      if (attachment.attachmentIsInserted) return false;
      if (thread?.threadImage?.displayMode == 'cover' &&
          thread?.threadImage?.link == attachment.links.permalink) return false;
      if (attachment.attachmentWidth == null ||
          attachment.attachmentWidth < 1 ||
          attachment.attachmentHeight == null ||
          attachment.attachmentHeight < 1) return false;

      return true;
    })?.toList();

    if (attachments?.isNotEmpty != true) return SizedBox.shrink();

    return _PostAttachmentsWidget(attachments);
  }
}
