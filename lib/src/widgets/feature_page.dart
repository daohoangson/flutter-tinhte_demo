import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../screens/fp_view.dart';

const _kFpBoxColor = Color(0xFFFFFFFF);
const _kFpBoxShadowColor = Color(0xFFDEDEE0);

class FpWidget extends StatelessWidget {
  final FeaturePage fp;

  FpWidget(this.fp);

  @override
  Widget build(BuildContext context) => _buildGestureDetector(
        context,
        _buildBox(
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

  Widget _buildBox(Widget head, Widget body) => Padding(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _kFpBoxColor,
            borderRadius: BorderRadius.circular(5),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _kFpBoxShadowColor,
                offset: Offset(0, 1),
                blurRadius: 2,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: ClipRRect(
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
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 5),
      );

  Widget _buildGestureDetector(BuildContext context, Widget child) =>
      GestureDetector(
        child: child,
        onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FpViewScreen(fp)),
            ),
      );
}
