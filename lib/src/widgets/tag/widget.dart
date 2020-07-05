import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/fp_view.dart';

const kTagWidgetPadding = 2.5;

class FpWidget extends StatelessWidget {
  static final kPreferAspectRatio = 1.3;
  static final kPreferWidth = 150.0;

  final FeaturePage fp;

  FpWidget(this.fp);

  @override
  Widget build(BuildContext context) => TagWidget(
        image: fp?.links?.thumbnail ?? fp?.links?.image,
        label: fp?.fullName,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FpViewScreen(fp)),
        ),
      );
}

class TagWidget extends StatelessWidget {
  final String image;
  final String label;
  final GestureTapCallback onTap;

  TagWidget({
    this.image,
    Key key,
    this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _buildGestureDetector(
        context,
        _buildBox(
          context,
          image?.isNotEmpty == true
              ? Image(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                )
              : null,
          LayoutBuilder(
            builder: (_, bc) => Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                child: Text(
                  label ?? l(context).loadingEllipsis,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: bc.biggest.height / 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
            ),
          ),
        ),
      );

  Widget _buildBox(BuildContext context, Widget head, Widget body) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryVariant,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
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
                child: body,
                style: TextStyle(color: theme.colorScheme.onSecondary),
              ),
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: onTap,
      );
}
