part of '../posts.dart';

class _PostAttachmentsWidget extends StatelessWidget {
  final List<Attachment> attachments;
  final LbTrigger lbTrigger;

  _PostAttachmentsWidget._(this.attachments, this.lbTrigger);

  static Widget? forPost(Post post, {Thread? thread}) {
    final attachments = <Attachment>[];
    final lbTrigger = LbTrigger();
    for (final attachment in post.attachments) {
      if (attachment.attachmentIsInserted == true) {
        // skip images that have been inserted into post body
        continue;
      }

      if (thread?.threadImage?.displayMode == 'cover' &&
          thread?.threadImage?.link == attachment.links?.permalink) {
        // skip thread cover image
        continue;
      }

      if (thread?.threadPrimaryImage?.displayMode == 'cover' &&
          thread?.threadPrimaryImage?.link == attachment.links?.permalink) {
        // skip thread cover image
        continue;
      }

      final aspectRatio = attachment.aspectRatio;
      final thumbnailUrl = attachment.links?.thumbnail;
      if (aspectRatio == null || thumbnailUrl == null) {
        // skip unknown attachments
        continue;
      }

      final caption = Text(attachment.filename ?? '');

      if (attachment.isVideo) {
        final videoUrl = attachment.links?.xVideoUrl;
        if (videoUrl != null) {
          lbTrigger.addSource(
            LbTriggerSource.video(videoUrl, aspectRatio: aspectRatio),
            caption: caption,
          );
          attachments.add(attachment);
          continue;
        }
      }

      final imageUrl = attachment.links?.data;
      if (imageUrl != null) {
        lbTrigger.addSource(
          LbTriggerSource.image(imageUrl),
          caption: caption,
        );
        attachments.add(attachment);
      }
    }

    if (attachments.isEmpty) return null;

    return _PostAttachmentsWidget._(attachments, lbTrigger);
  }

  @override
  Widget build(BuildContext context) {
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
        aspectRatio: attachment.aspectRatio!,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: buildCachedNetworkImage(attachment.links!.thumbnail!),
        ),
      );
}
