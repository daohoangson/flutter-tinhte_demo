import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/bookmark_list.dart';
import 'package:the_app/src/screens/my_feed.dart';
import 'package:the_app/src/screens/notification_list.dart';
import 'package:the_app/src/screens/register.dart';
import 'package:the_app/src/widgets/menu/dark_theme.dart';
import 'package:the_app/src/widgets/app_bar.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/link.dart';
import 'package:the_app/src/widgets/menu/developer.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext _) => Consumer<User>(
        builder: (context, user, _) => Scaffold(
          appBar: AppBar(
            title: Text(l(context).menu),
          ),
          body: ListView(
            children: <Widget>[
              AppBarDrawerHeader(),
              _buildRegister(context, user),
              MenuDarkTheme(),
              _buildBookmarkList(context, user),
              _buildMyFeed(context, user),
              _buildNotifications(context, user),
              AppBarDrawerFooter(),
              _buildPrivacyPolicy(context),
              DeveloperMenu(),
              PackageInfoWidget(),
            ],
          ),
        ),
      );

  Widget _buildBookmarkList(BuildContext context, User user) =>
      config.apiBookmarkPath?.isNotEmpty == true && user.userId > 0
          ? ListTile(
              title: Text(l(context).threadBookmarkList),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => BookmarkListScreen())),
            )
          : const SizedBox.shrink();

  Widget _buildMyFeed(BuildContext context, User user) =>
      config.myFeed == true && user.userId > 0
          ? ListTile(
              title: Text(l(context).myFeed),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => MyFeedScreen())),
            )
          : const SizedBox.shrink();

  Widget _buildNotifications(BuildContext context, User user) => user.userId > 0
      ? ListTile(
          title: Text(l(context).notifications),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => NotificationListScreen())),
        )
      : const SizedBox.shrink();

  Widget _buildPrivacyPolicy(BuildContext context) => ListTile(
        title: Text(l(context).privacyPolicy),
        onTap: () => launchLink(context, config.linkPrivacyPolicy),
      );

  Widget _buildRegister(BuildContext context, User user) => user.userId == 0
      ? ListTile(
          title: Text(l(context).register),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => RegisterScreen())),
        )
      : const SizedBox.shrink();
}
