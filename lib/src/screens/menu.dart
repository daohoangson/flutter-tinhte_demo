import 'package:flutter/material.dart';

import '../screens/notification_list.dart';
import '../widgets/menu/dark_theme.dart';
import '../widgets/app_bar.dart';

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
          ],
        ),
      );

  Widget _buildNotifications(BuildContext context) => ListTile(
        title: Text('Notifications'),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => NotificationListScreen())),
      );
}
