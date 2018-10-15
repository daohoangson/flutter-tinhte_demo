import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tinhte_api/oauth_token.dart';
import 'package:tinhte_api/user.dart';

import '../../screens/login.dart';
import '../_api.dart';

class HomeDrawerHeader extends StatefulWidget {
  final OauthToken token;

  HomeDrawerHeader({Key key, @required this.token}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeDrawerHeaderState();
}

class _HomeDrawerHeaderState extends State<HomeDrawerHeader> {
  bool hasFetchedUser = false;
  User user;

  @override
  Widget build(BuildContext context) {
    if (widget.token != null && user == null) _fetchUser();

    final child = widget.token == null
        ? GestureDetector(
            child: Text('Login'),
            onTap: () => pushLoginScreen(context),
          )
        : user == null
            ? Text('Welcome back!')
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: CircleAvatar(
                      minRadius: 20.0,
                      child: CachedNetworkImage(
                        imageUrl: user.links.avatarBig,
                        fit: BoxFit.cover,
                      ),
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

    return DrawerHeader(
      child: child,
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
      ),
    );
  }

  void _fetchUser() async {
    if (hasFetchedUser || widget.token == null) return;
    setState(() => hasFetchedUser = true);

    final api = ApiInheritedWidget.of(context).api;
    final usersMe = "users/me?oauth_token=${widget.token.accessToken}";
    final json = await api.getJson(usersMe);
    final m = json as Map<String, dynamic>;
    final newUser = m.containsKey('user') ? User.fromJson(m['user']) : null;
    setState(() => user = newUser);
  }
}
