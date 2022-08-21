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
import 'package:the_app/src/widgets/menu/dev_tools.dart';
import 'package:the_app/src/widgets/menu/package_info.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<User>(
        builder: (context, user, _) => Scaffold(
          appBar: AppBar(
            title: Text(l(context).menu),
          ),
          body: ListView(
            children: <Widget>[
              const AppBarDrawerHeader(),
              _buildRegister(context, user),
              const MenuDarkTheme(),
              _buildBookmarkList(context, user),
              _buildMyFeed(context, user),
              _buildNotifications(context, user),
              const AppBarDrawerFooter(),
              _buildPrivacyPolicy(context),
              const DeveloperMenu(),
              const PackageInfoWidget(),
            ],
          ),
        ),
      );

  Widget _buildBookmarkList(BuildContext context, User user) =>
      config.apiBookmarkPath?.isNotEmpty == true && user.userId > 0
          ? ListTile(
              title: Text(l(context).threadBookmarkList),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const BookmarkListScreen())),
            )
          : const SizedBox.shrink();

  Widget _buildMyFeed(BuildContext context, User user) =>
      config.myFeed == true && user.userId > 0
          ? ListTile(
              title: Text(l(context).myFeed),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyFeedScreen())),
            )
          : const SizedBox.shrink();

  Widget _buildNotifications(BuildContext context, User user) => user.userId > 0
      ? ListTile(
          title: Text(l(context).notifications),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const NotificationListScreen())),
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
              .push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
        )
      : const SizedBox.shrink();
}
