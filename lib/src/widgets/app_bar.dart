import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/user.dart';

import '../screens/login.dart';
import '../screens/notification_list.dart';
import '../api.dart';
import '../link.dart';
import '../push_notification.dart';

AppBar buildAppBar({Widget title}) => AppBar(
      title: title,
      actions: <Widget>[
        AppBarNotificationButton(),
      ],
    );

class AppBarDrawerHeader extends StatelessWidget {
  AppBarDrawerHeader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext _) => Consumer<User>(
        builder: (context, user, _) => user.userId > 0
            ? DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                ),
                child: _buildVisitorPanel(context, user))
            : ListTile(
                title: const Text('Login'),
                onTap: () => Navigator.push(context, LoginScreenRoute()),
              ),
      );

  Widget _buildAvatar(User user) => AspectRatio(
        aspectRatio: 1.0,
        child: CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(
            user.links?.avatarBig,
          ),
        ),
      );

  Widget _buildVisitorPanel(BuildContext context, User user) {
    Widget built = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Center(child: _buildAvatar(user))),
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: <TextSpan>[
                _compileUsername(context, user),
                _compileUserRank(context, user),
              ],
            ),
          ),
        ),
      ],
    );

    if (user.userId > 0) {
      built = GestureDetector(
        child: built,
        onTap: () => launchMemberView(context, user.userId),
      );
    }

    return built;
  }

  TextSpan _compileUserRank(BuildContext context, User user) => TextSpan(
        text: " ${user.rank?.rankName ?? ''}",
        style: Theme.of(context).textTheme.subhead.copyWith(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold,
            ),
      );

  TextSpan _compileUsername(BuildContext context, User user) => TextSpan(
        text: user.username ?? '',
        style: Theme.of(context).textTheme.title.copyWith(
              color: Theme.of(context).accentColor,
            ),
      );
}

class AppBarDrawerFooter extends StatelessWidget {
  AppBarDrawerFooter({Key key}) : super(key: key);

  Widget build(BuildContext _) => Consumer<ApiAuth>(
      builder: (context, apiAuth, __) => apiAuth.hasToken
          ? ListTile(
              title: const Text('Logout'),
              onTap: () => logout(context),
            )
          : SizedBox.shrink());
}

class AppBarNotificationButton extends StatelessWidget {
  final bool visibleOnZero;

  AppBarNotificationButton({
    this.visibleOnZero = false,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext _) => Consumer2<PushNotificationUnread, User>(
        builder: (context, unread, user, __) {
          if (user.userId == 0) return SizedBox.shrink();

          final value = unread.value;
          final onPressed = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationListScreen()),
              );

          if (value == 0) {
            if (!visibleOnZero) return SizedBox.shrink();

            return IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: onPressed,
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: onPressed,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    child: Text(value > 99 ? '99+' : "$value"),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(3),
                    padding: const EdgeInsets.all(7),
                  ),
                ),
              )
            ],
          );
        },
      );
}
