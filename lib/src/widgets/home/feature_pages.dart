import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';
import 'package:tinhte_api/user.dart';

import '../../api.dart';
import '../../intl.dart';
import 'header.dart';

const _kImageWidth = 300.0;
const _kImageAspectRatio = 114 / 72;
const _kInfoHeight = 75.0;

class FeaturePagesWidget extends StatefulWidget {
  final List<FeaturePage> pages;

  FeaturePagesWidget(this.pages, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeaturePagesWidgetState();
}

class _FeaturePagesWidgetState extends State<FeaturePagesWidget> {
  User _user;

  List<FeaturePage> get pages => widget.pages;

  @override
  void initState() {
    super.initState();
    if (pages?.isEmpty == true) fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = ApiData.of(context).user;
    if (user != _user) {
      // don't use setState to avoid wasting a build cycle
      _user = user;

      // have to fetch feature pages on login because
      // the follow link is null for guest...
      fetch();
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        shape: RoundedRectangleBorder(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HeaderWidget('Cộng đồng'),
            SizedBox(
              height: _kImageWidth / _kImageAspectRatio + _kInfoHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) =>
                    _FpWidget(i < pages.length ? pages[i] : null),
                itemCount: max(min(pages.length, 5), 1),
              ),
            ),
            Center(
              child: FlatButton(
                child: Text('View all communities'),
                textColor: Theme.of(context).accentColor,
                onPressed: null,
              ),
            ),
          ],
        ),
      );

  void fetch() => apiGet(
        this,
        'feature-pages?order=7_days_thread_count_desc',
        onSuccess: (jsonMap) {
          final List<FeaturePage> newPages = List();

          if (jsonMap.containsKey('pages')) {
            final js = jsonMap['pages'] as List;
            js.forEach((j) => newPages.add(FeaturePage.fromJson(j)));
          }

          setState(() {
            pages.clear();
            pages.addAll(
              newPages.where((fp) => fp.links?.image?.isNotEmpty == true),
            );
          });
        },
      );
}

typedef void FeaturePagesAddAll(List<FeaturePage> list);

class _FpWidget extends StatefulWidget {
  final FeaturePage fp;

  _FpWidget(this.fp);

  @override
  State<StatefulWidget> createState() => _FpWidgetState();
}

class _FpWidgetState extends State<_FpWidget> {
  int get followerCount => fp?.values?.followerCount ?? 0;
  FeaturePage get fp => widget.fp;
  bool get isFollowed => fp?.isFollowed == true;
  bool isFollowing = false;
  String get linkFollow => fp?.links?.follow;

  set followerCount(int value) => fp?.values?.followerCount = value;
  set isFollowed(bool value) => fp?.isFollowed = value;

  @override
  Widget build(BuildContext context) => _buildCard(
        <Widget>[
          AspectRatio(
            aspectRatio: _kImageAspectRatio,
            child: fp?.links?.image?.isNotEmpty == true
                ? CachedNetworkImage(
                    imageUrl: fp.links.image,
                    fit: BoxFit.cover,
                  )
                : fp == null
                    ? const Center(child: CircularProgressIndicator())
                    : null,
          ),
          SizedBox(
            height: _kInfoHeight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        fp?.fullName ?? '',
                        style: Theme.of(context).textTheme.title,
                      ),
                      fp != null
                          ? GestureDetector(
                              child: isFollowed
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFFC7E1F),
                                    )
                                  : const Icon(Icons.check_circle_outline),
                              onTap: isFollowed ? _unfollow : _follow,
                            )
                          : Container(height: 0.0, width: 0.0),
                    ],
                  ),
                  followerCount > 0
                      ? Text(
                          "${formatNumber(followerCount)} Followers",
                          style: Theme.of(context).textTheme.caption,
                        )
                      : Container(height: 0.0, width: 0.0),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildCard(List<Widget> children) => SizedBox(
        width: _kImageWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              border: Border.all(color: const Color(0xFFEEEDF2)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFDEDEE0),
                  spreadRadius: 1.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      );

  _follow() => prepareForApiAction(this, () {
        if (isFollowing) return;
        if (linkFollow?.isNotEmpty != true) return;

        setState(() => isFollowing = true);
        apiPost(this, linkFollow,
            onSuccess: (_) => setState(() {
                  isFollowed = true;
                  followerCount++;
                }),
            onComplete: () => setState(() => isFollowing = false));
      });

  _unfollow() => prepareForApiAction(this, () {
        if (isFollowing) return;
        if (linkFollow?.isNotEmpty != true) return;

        setState(() => isFollowing = true);
        apiDelete(this, linkFollow,
            onSuccess: (_) => setState(() {
                  isFollowed = false;
                  if (followerCount > 0) followerCount--;
                }),
            onComplete: () => setState(() => isFollowing = false));
      });
}
