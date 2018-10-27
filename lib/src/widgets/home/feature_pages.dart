import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/feature_page.dart';

import '../../screens/fp_view.dart';
import '../../api.dart';
import '../../constants.dart';
import '../../intl.dart';
import 'header.dart';

const _kImageWidth = 300.0;
const _kImageAspectRatio = 114 / 72;
const _kInfoHeight = 75.0;

class FeaturePagesWidget extends StatefulWidget {
  final List<FeaturePage> pages;

  FeaturePagesWidget(this.pages, {Key key})
      : assert(pages != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _FeaturePagesWidgetState();
}

class _FeaturePagesWidgetState extends State<FeaturePagesWidget> {
  List<FeaturePage> get pages => widget.pages;

  @override
  void initState() {
    super.initState();
    if (pages.isEmpty == true) fetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = ApiData.of(context).user;
    if (pages?.isNotEmpty == true) {
      final hasLinkFollow = pages.first.links?.follow?.isNotEmpty == true;
      if (hasLinkFollow == (user == null)) {
        // if no user but fp has link -> fetch
        // if has user but fp doesn't have link -> also fetch
        fetch();
      }
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
                itemCount: max(pages.length, 1),
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

  fetch() {
    final List<String> pageIds = List();
    final List<FeaturePage> allPages = List();

    final _sortPages = () {
      if (pageIds.length == 0 || allPages.length == 0) return;

      final List<FeaturePage> filtered = List();
      for (final fpId in pageIds) {
        final fp = allPages.firstWhere((fp) => fp.id == fpId);
        if (fp == null) continue;
        filtered.add(fp);
      }

      setState(() => pages.addAll(filtered));
    };

    apiGet(this, 'posts/50265722?fields_include=post_body_plain_text',
        onSuccess: (jsonMap) {
      if (jsonMap.containsKey('post')) {
        final post = jsonMap['post'] as Map;
        if (post.containsKey('post_body_plain_text')) {
          final list = post['post_body_plain_text'] as String;
          pageIds.addAll(list.split('\n'));
        }
      }

      _sortPages();
    });

    apiGet(
      this,
      'feature-pages?order=7_days_thread_count_desc',
      onSuccess: (jsonMap) {
        if (jsonMap.containsKey('pages')) {
          final js = jsonMap['pages'] as List;
          js.forEach((j) => allPages.add(FeaturePage.fromJson(j)));
        }

        _sortPages();
      },
    );
  }
}

class _FpWidget extends StatefulWidget {
  final FeaturePage fp;

  _FpWidget(this.fp);

  @override
  State<StatefulWidget> createState() => _FpWidgetState();
}

class _FpWidgetState extends State<_FpWidget> {
  int get followerCount => fp?.values?.followerCount ?? 0;
  FeaturePage get fp => widget.fp;
  String get image => fp?.links?.image;
  bool get isFollowed => fp?.isFollowed == true;
  bool isFollowing = false;
  String get linkFollow => fp?.links?.follow;

  set followerCount(int value) => fp?.values?.followerCount = value;
  set isFollowed(bool value) => fp?.isFollowed = value;

  @override
  Widget build(BuildContext context) => _buildGestureDetector(
        _buildBox(
          image?.isNotEmpty == true
              ? Image(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                )
              : fp == null
                  ? const Center(child: CircularProgressIndicator())
                  : null,
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildFullName(),
                    _buildFollowerButton(),
                  ],
                ),
                _buildFollowerCount(),
              ],
            ),
          ),
        ),
      );

  Widget _buildBox(Widget head, Widget body) => SizedBox(
        width: _kImageWidth,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: kColorHomeFpBox,
              border: Border.all(color: kColorHomeFpBoxBorder),
              boxShadow: <BoxShadow>[
                BoxShadow(color: kColorHomeFpBoxShadow, spreadRadius: 1.0),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: _kImageAspectRatio,
                  child: head,
                ),
                SizedBox(
                  height: _kInfoHeight,
                  child: body,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFollowerButton() => fp != null
      ? GestureDetector(
          child: isFollowed
              ? const Icon(
                  Icons.check_circle,
                  color: kColorHomeFpCheckedIcon,
                )
              : const Icon(Icons.check_circle_outline),
          onTap: isFollowed ? _unfollow : _follow,
        )
      : Container(height: 0.0, width: 0.0);

  Widget _buildFollowerCount() => followerCount > 0
      ? Text(
          "${formatNumber(followerCount)} Followers",
          style: Theme.of(context).textTheme.caption,
        )
      : Container(height: 0.0, width: 0.0);

  Widget _buildFullName() => Text(
        fp?.fullName ?? '',
        style: Theme.of(context).textTheme.title,
      );

  Widget _buildGestureDetector(Widget child) => GestureDetector(
        child: child,
        onTap: () => pushFpViewScreen(context, fp),
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
