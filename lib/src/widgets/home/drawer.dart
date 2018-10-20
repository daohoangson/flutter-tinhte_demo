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
  VoidCallback _removeListener;
  OauthToken _token;
  User _user;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = ApiInheritedWidget.of(context)
        .addApiUserListener((newToken, newUser) => setState(() {
              _token = newToken;
              _user = newUser;
            }));
  }

  @override
  void deactivate() {
    if (_removeListener != null) {
      _removeListener();
      _removeListener = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
        ),
        child: _token == null
            ? GestureDetector(
                child: Text('Login'),
                onTap: () => pushLoginScreen(context),
              )
            : _user == null
                ? Text('Welcome back, we are loading user profile...')
                : _buildVisitorPanel(),
      );

  Widget _buildVisitorPanel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(_user.links.avatarBig),
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
                    text: _user.username,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: " ${_user.rank.rankName}"),
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
  VoidCallback _removeListener;
  OauthToken _token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_removeListener != null) _removeListener();
    _removeListener = ApiInheritedWidget.of(context)
        .addApiTokenListener((newToken) => setState(() => _token = newToken));
  }

  @override
  void deactivate() {
    if (_removeListener != null) {
      _removeListener();
      _removeListener = null;
    }

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => _token != null
      ? ListTile(
          title: Text('Logout'),
          onTap: () => ApiInheritedWidget.of(context).api.logout(),
        )
      : Container(height: 0.0, width: 0.0);
}
