import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/user.dart';

import '../../screens/login.dart';
import '../../api.dart';

class HomeDrawerHeader extends StatefulWidget {
  HomeDrawerHeader({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    final apiData = ApiData.of(context);
    final hasToken = apiData.hasToken;
    final user = apiData.user;

    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
      child: hasToken
          ? user != null
              ? _buildVisitorPanel(user)
              : Text('Welcome back, we are loading user profile...')
          : GestureDetector(
              child: Text('Login'),
              onTap: () => pushLoginScreen(context),
            ),
    );
  }

  Widget _buildVisitorPanel(User user) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundImage: user?.links?.avatarBig?.isNotEmpty == true
                  ? CachedNetworkImageProvider(user.links.avatarBig)
                  : null,
              minRadius: 20.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: user?.username ?? '',
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " ${user?.rank?.rankName ?? ''}"),
                ],
              ),
            ),
          ),
        ],
      );
}

class HomeDrawerFooter extends StatefulWidget {
  HomeDrawerFooter({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeDrawerFooterState();
}

class _HomeDrawerFooterState extends State<HomeDrawerFooter> {
  @override
  Widget build(BuildContext context) => ApiData.of(context).hasToken
      ? ListTile(
          title: Text('Logout'),
          onTap: () => logout(this),
        )
      : Container(height: 0.0, width: 0.0);
}
