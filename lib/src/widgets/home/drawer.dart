import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';

import '../../screens/login.dart';
import '../_api.dart';

class HomeDrawerHeader extends StatefulWidget {
  HomeDrawerHeader({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
  ApiUserListener apiUserListener;
  OauthToken token;
  User user;

  @override
  void initState() {
    super.initState();
    apiUserListener = (newToken, newUser) => setState(() {
          token = newToken;
          user = newUser;
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ApiInheritedWidget.of(context).addApiUserListener(apiUserListener);
  }

  @override
  void deactivate() {
    ApiInheritedWidget.of(context).removeApiUserListener(apiUserListener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
        ),
        child: token == null
            ? GestureDetector(
                child: Text('Login'),
                onTap: () => pushLoginScreen(context),
              )
            : user == null
                ? Text('Welcome back, we are loading user profile...')
                : _buildVisitorPanel(),
      );

  Widget _buildVisitorPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.links.avatarBig),
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
                    text: user.username,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " ${user.rank.rankName}"),
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
  ApiTokenListener apiTokenListener;
  OauthToken token;

  @override
  void initState() {
    super.initState();
    apiTokenListener = (newToken) => setState(() => token = newToken);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ApiInheritedWidget.of(context).addApiTokenListener(apiTokenListener);
  }

  @override
  void deactivate() {
    ApiInheritedWidget.of(context).removeApiTokenListener(apiTokenListener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => token != null
      ? ListTile(
          title: Text('Logout'),
          onTap: () => ApiInheritedWidget.of(context).api.logout(),
        )
      : Container(height: 0.0, width: 0.0);
}
