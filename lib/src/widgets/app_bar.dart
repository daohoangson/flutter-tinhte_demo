import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/user.dart';
import 'package:tinhte_demo/src/screens/login.dart';
import 'package:tinhte_demo/src/api.dart';
import 'package:tinhte_demo/src/link.dart';

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
