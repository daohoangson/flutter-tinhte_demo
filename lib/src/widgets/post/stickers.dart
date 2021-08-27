part of '../posts.dart';

class _PostStickersWidget extends StatelessWidget {
  final List<PostSticker> stickers;

  _PostStickersWidget(this.stickers);

  @override
  Widget build(BuildContext context) {
    final lbTrigger = LbTrigger();
    for (final sticker in stickers) {
      lbTrigger.addSource(
        LbTriggerSource.image(sticker.links.imageDataUrl),
        caption: Text(sticker.stickerName),
      );
    }

    return Padding(
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
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    );
  }

  Widget _buildSticker(PostSticker sticker) => AspectRatio(
        aspectRatio: sticker.imageWidth / sticker.imageHeight,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: buildCachedNetworkImage(sticker.links.imageUrl),
        ),
      );

  static Widget forPost(Post post) {
    final stickers = post.stickers;
    if (stickers?.isNotEmpty != true) return null;

    return _PostStickersWidget(stickers);
  }
}
