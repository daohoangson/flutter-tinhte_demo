import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import '../screens/notification_list.dart';
import '../widgets/menu/dark_theme.dart';
import '../widgets/app_bar.dart';
import '../link.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Menu'),
        ),
        body: ListView(
          children: <Widget>[
            AppBarDrawerHeader(),
            MenuDarkTheme(),
            _buildNotifications(context),
            AppBarDrawerFooter(),
            _buildPrivacyPolicy(context),
            _PackageInfoWidget(),
          ],
        ),
      );

  Widget _buildNotifications(BuildContext context) => ListTile(
        title: Text('Notifications'),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => NotificationListScreen())),
      );

  Widget _buildPrivacyPolicy(BuildContext context) => ListTile(
        title: Text('Privacy Policy'),
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
      title: Text('Version'),
      subtitle: Text(_info != null
          ? "${_info.version} (build number: ${_info.buildNumber})"
          : 'N/A'));
}
