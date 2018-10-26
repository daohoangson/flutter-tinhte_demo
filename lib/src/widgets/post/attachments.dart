part of '../posts.dart';

const kAttachmentSize = 100.0;

class _PostAttachmentsWidget extends StatelessWidget {
  final List<Attachment> attachments;

  _PostAttachmentsWidget(this.attachments);

  @override
  Widget build(BuildContext context) {
    final lbTrigger = LbTrigger(context);
    for (final attachment in attachments) {
      lbTrigger.sources.add(attachment.links.data);
    }

    return SizedBox(
      height: kAttachmentSize,
      child: ListView.separated(
        itemBuilder: (context, i) => lbTrigger.buildGestureDetector(
            i, _buildAttachment((attachments[i]))),
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

  static _PostAttachmentsWidget forPost(Post post) {
    final attachments = post.attachments
        ?.where((attachment) => !attachment.attachmentIsInserted)
        ?.toList();
    if (attachments?.isNotEmpty != true) return null;

    return _PostAttachmentsWidget(attachments);
  }
}
