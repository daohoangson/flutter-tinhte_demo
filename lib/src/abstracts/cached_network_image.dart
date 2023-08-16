import 'package:cached_network_image/cached_network_image.dart' as lib;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as lib;

@visibleForTesting
lib.BaseCacheManager? debugCacheManager;

lib.BaseCacheManager get manager =>
    debugCacheManager ?? lib.DefaultCacheManager();

ImageProvider image(String url) =>
    lib.CachedNetworkImageProvider(url, cacheManager: manager);

class ImageWidget extends StatelessWidget {
  final String imageUrl;

  const ImageWidget(this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return lib.CachedNetworkImage(
      cacheManager: manager,
      errorWidget: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
      ),
      fit: BoxFit.cover,
      imageUrl: imageUrl,
    );
  }
}
