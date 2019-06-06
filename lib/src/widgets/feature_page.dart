import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../screens/fp_view.dart';

class FpWidget extends StatelessWidget {
  static final kPreferAspectRatio = 1.25;
  static final kPreferWidth = 150.0;

  final FeaturePage fp;

  FpWidget(this.fp);

  @override
  Widget build(BuildContext context) => _buildGestureDetector(
        context,
        _buildBox(
          context,
          fp?.links?.image?.isNotEmpty == true
              ? Image(
                  image: CachedNetworkImageProvider(
                    fp.links.thumbnail ?? fp.links.image,
                  ),
                  fit: BoxFit.cover,
                )
              : null,
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              fp?.fullName ?? 'Loading...',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
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
          child: AspectRatio(
            aspectRatio: kPreferAspectRatio,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 2,
                  child: head,
                ),
                Expanded(
                  child: Align(child: body, alignment: Alignment.centerLeft),
                ),
              ],
            ),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 5),
    );
  }

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FpViewScreen(fp)),
            ),
      );
}
