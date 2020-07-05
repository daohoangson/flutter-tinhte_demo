import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/bookmark_list.dart';
import 'package:the_app/src/screens/notification_list.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';
import 'package:the_app/src/widgets/app_bar.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/link.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(l(context).menu),
        ),
        body: ListView(
          children: <Widget>[
            AppBarDrawerHeader(),
            MenuDarkTheme(),
            _buildBookmarkList(context),
            _buildNotifications(context),
            AppBarDrawerFooter(),
            _buildPrivacyPolicy(context),
            _PackageInfoWidget(),
          ],
        ),
      );

  Widget _buildBookmarkList(BuildContext context) =>
      config.apiBookmarkPath?.isNotEmpty == true
          ? ListTile(
              title: Text(l(context).threadBookmarkList),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookmarkListScreen())),
            )
          : const SizedBox.shrink();

  Widget _buildNotifications(BuildContext context) => ListTile(
        title: Text(l(context).notifications),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => NotificationListScreen())),
      );

  Widget _buildPrivacyPolicy(BuildContext context) => ListTile(
        title: Text(l(context).privacyPolicy),
        onTap: () => launchLink(context, 'https://tinhte.vn/threads/2864415/'),
      );
}

class _PackageInfoWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PackageInfoState();
}

class _PackageInfoState extends State<_PackageInfoWidget> {
  PackageInfo _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) => setState(() => _info = info));
  }

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(l(context).appVersion),
      subtitle: Text(_info != null
          ? l(context).appVersionInfo(_info.version, _info.buildNumber)
          : l(context).appVersionNotAvailable));
}
