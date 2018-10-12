import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:tinhte_demo/api/model/feature_page.dart';
import 'header.dart';

const _columnWidth = .3;
const _imageAspectRatio = 114 / 72;
const _nameHeight = 20.0;
const _spacingVertical = 5.0;

class FeaturePagesWidget extends StatelessWidget {
  final List<FeaturePage> pages;

  FeaturePagesWidget({Key key, this.pages}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HeaderWidget('Cộng đồng'),
          SizedBox(
            height: (_spacingVertical +
                    MediaQuery.of(context).size.width *
                        _columnWidth /
                        _imageAspectRatio +
                    _spacingVertical +
                    _nameHeight +
                    _spacingVertical) *
                2,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) =>
                  _buildColumn(context, pages[i * 2], pages[i * 2 + 1]),
              itemCount: min((pages.length / 2).floor(), 7),
            ),
          ),
        ],
      );

  Widget _buildColumn(BuildContext context, FeaturePage fp1, FeaturePage fp2) =>
      SizedBox(
        width: MediaQuery.of(context).size.width * _columnWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildRowImage(fp1),
            _buildRowName(fp1),
            _buildRowImage(fp2),
            _buildRowName(fp2),
          ],
        ),
      );

  Widget _buildRowImage(FeaturePage fp) => Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 5.0, vertical: _spacingVertical),
        child: AspectRatio(
          aspectRatio: _imageAspectRatio,
          child: fp?.links?.image?.isNotEmpty == true
              ? Image(
                  image: CachedNetworkImageProvider(fp.links.image),
                  fit: BoxFit.cover,
                )
              : null,
        ),
      );

  Widget _buildRowName(FeaturePage fp) => Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 2 * _spacingVertical),
        child: SizedBox(
          height: _nameHeight,
          child: Text(
            fp?.fullName ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _nameHeight - 6.0,
            ),
          ),
        ),
      );
}
