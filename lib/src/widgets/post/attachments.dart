part of '../posts.dart';

class _PostAttachmentsWidget extends StatelessWidget {
  final List<Attachment> attachments;

  _PostAttachmentsWidget(this.attachments);

  @override
  Widget build(BuildContext context) {
    final lbTrigger = LbTrigger();
    for (final attachment in attachments) {
      lbTrigger.addSource(
        attachment.isVideo
            ? LbTriggerSource.video(
                attachment.links.xVideoUrl,
                aspectRatio: attachment.aspectRatio,
              )
            : LbTriggerSource.image(attachment.links.data),
        caption: Text(attachment.filename),
      );
    }

    return Padding(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          itemBuilder: (c, i) => lbTrigger.buildGestureDetector(
              c, _buildAttachment(attachments[i]), i),
          itemCount: attachments.length,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, _) => const SizedBox(width: 10.0),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    );
  }

  Widget _buildAttachment(Attachment attachment) => AspectRatio(
        aspectRatio: attachment.aspectRatio,
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
      if (thread?.threadPrimaryImage?.displayMode == 'cover' &&
          thread?.threadPrimaryImage?.link == attachment.links.permalink)
        return false;
      return attachment.aspectRatio != null &&
          attachment.links?.thumbnail?.isNotEmpty == true;
    })?.toList();

    if (attachments?.isNotEmpty != true) return null;

    return _PostAttachmentsWidget(attachments);
  }
}
