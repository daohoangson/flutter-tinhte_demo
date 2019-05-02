part of '../posts.dart';

const kAttachmentSize = 100.0;

class _PostAttachmentsWidget extends StatelessWidget {
  final List<Attachment> attachments;

  _PostAttachmentsWidget(this.attachments);

  @override
  Widget build(BuildContext context) {
    final lbTrigger = LbTrigger();
    for (final attachment in attachments) {
      lbTrigger.sources.add(attachment.links.data);
    }

    return SizedBox(
      height: kAttachmentSize,
      child: ListView.separated(
        itemBuilder: (context, i) => lbTrigger.buildGestureDetector(
            context, i, _buildAttachment((attachments[i]))),
        itemCount: attachments.length,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, i) => const SizedBox(width: 10.0),
      ),
    );
  }

  Widget _buildAttachment(Attachment attachment) => CachedNetworkImage(
        imageUrl: attachment.links.thumbnail,
        fit: BoxFit.cover,
        height: kAttachmentSize,
        width: kAttachmentSize,
      );

  static Widget forPost(Post post, {Thread thread}) {
    final attachments = post.attachments?.where((attachment) {
      if (attachment.attachmentIsInserted) return false;
      if (thread?.threadImage?.displayMode == 'cover' &&
          thread?.threadImage?.link == attachment.links.permalink) return false;

      return true;
    })?.toList();

    if (attachments?.isNotEmpty != true) return Container();

    return _PostAttachmentsWidget(attachments);
  }
}
