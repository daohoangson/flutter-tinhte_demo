part of '../posts.dart';

class _PostStickersWidget extends StatelessWidget {
  final LbTrigger lbTrigger;
  final List<PostSticker> stickers;

  const _PostStickersWidget._(this.lbTrigger, this.stickers);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          itemBuilder: (c, i) =>
              lbTrigger.buildGestureDetector(c, _buildSticker(stickers[i]), i),
          itemCount: stickers.length,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, _) => const SizedBox(width: 10.0),
        ),
      ),
    );
  }

  Widget _buildSticker(PostSticker sticker) {
    final width = sticker.imageWidth ?? 0;
    final height = sticker.imageHeight ?? 0;
    final aspectRatio = height != 0 ? width / height : 1.0;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: cached.ImageWidget(sticker.links?.imageUrl ?? ''),
      ),
    );
  }

  static Widget? forPost(Post post) {
    final lbTrigger = LbTrigger();
    final stickers = <PostSticker>[];

    for (final sticker in post.stickers ?? []) {
      final imageUrl = sticker.links?.imageDataUrl ?? '';
      if (imageUrl.isNotEmpty) {
        lbTrigger.addSource(
          LbTriggerSource.image(imageUrl),
          caption: Text(sticker.stickerName ?? '#${sticker.stickerId}'),
        );
        stickers.add(sticker);
      }
    }

    if (stickers.isEmpty) return null;

    return _PostStickersWidget._(lbTrigger, stickers);
  }
}
