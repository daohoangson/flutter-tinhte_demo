import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:the_api/feature_page.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/fp_view.dart';

class FpWidget extends StatelessWidget {
  static const kPreferAspectRatio = 1.3;
  static const kPreferWidth = 150.0;

  final FeaturePage? fp;

  const FpWidget(this.fp, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scopedFp = fp;

    return TagWidget(
      image: fp?.links?.thumbnail ?? fp?.links?.image,
      label: fp?.fullName,
      onTap: scopedFp != null
          ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FpViewScreen(scopedFp)),
              )
          : null,
    );
  }
}

class TagWidget extends StatelessWidget {
  final String? image;
  final String? label;
  final GestureTapCallback? onTap;

  const TagWidget({
    this.image,
    Key? key,
    this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = image ?? '';
    return _buildGestureDetector(
      context,
      _buildBox(
        context,
        imageUrl.isNotEmpty
            ? Image(
                image: CachedNetworkImageProvider(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
        LayoutBuilder(
          builder: (_, bc) => Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                label ?? l(context).loadingEllipsis,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: bc.biggest.height / 2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBox(BuildContext context, Widget? head, Widget body) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 2,
              child: head,
            ),
            AspectRatio(
              aspectRatio: 4,
              child: DefaultTextStyle(
                style: TextStyle(color: theme.colorScheme.onSecondary),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        onTap: onTap,
        child: child,
      );
}
