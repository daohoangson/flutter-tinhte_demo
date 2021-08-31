import 'package:freezed_annotation/freezed_annotation.dart';

part 'x_post_sticker.freezed.dart';
part 'x_post_sticker.g.dart';

@freezed
class PostSticker with _$PostSticker {
  const factory PostSticker(
    int stickerId, {
    int? categoryId,
    String? description,
    int? imageWidth,
    int? imageHeight,
    int? lastUsedDate,
    String? stickerName,
    int? stickerPostId,
    int? usedTotal,
    PostStickerLinks? links,
  }) = _PostSticker;

  factory PostSticker.fromJson(Map<String, dynamic> json) =>
      _$PostStickerFromJson(json);
}

@freezed
class PostStickerLinks with _$PostStickerLinks {
  const factory PostStickerLinks({
    String? detail,
    String? imageDataUrl,
    String? imageUrl,
    String? thumbnailUrl,
  }) = _PostStickerLinks;

  factory PostStickerLinks.fromJson(Map<String, dynamic> json) =>
      _$PostStickerLinksFromJson(json);
}
