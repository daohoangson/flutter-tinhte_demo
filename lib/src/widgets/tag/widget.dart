import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../screens/fp_view.dart';

const kTagWidgetPadding = 2.5;

class FpWidget extends StatelessWidget {
  static final kPreferAspectRatio = 1.25;
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
          Text(
            label ?? 'Loading...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _buildBox(BuildContext context, Widget head, Widget body) {
    final theme = Theme.of(context);

    return Padding(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.backgroundColor,
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
              Padding(
                child: body,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      padding: const EdgeInsets.all(kTagWidgetPadding),
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: onTap,
      );
}
