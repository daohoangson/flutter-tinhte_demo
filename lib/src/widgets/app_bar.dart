import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_api/user.dart';
import 'package:the_app/src/abstracts/cached_network_image.dart' as cached;
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/login.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/link.dart';

class AppBarDrawerHeader extends StatelessWidget {
  const AppBarDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) => Consumer<User>(
        builder: (context, user, _) => user.userId > 0
            ? DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).highlightColor,
                ),
                child: _buildVisitorPanel(context, user))
            : ListTile(
                title: Text(l(context).login),
                onTap: () => Navigator.push(context, LoginScreenRoute()),
              ),
      );

  Widget _buildAvatar(User user) {
    final avatar = user.links?.avatarBig;
    return AspectRatio(
      aspectRatio: 1.0,
      child: CircleAvatar(
        backgroundImage: avatar != null ? cached.image(avatar) : null,
      ),
    );
  }

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
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.bold,
            ),
      );

  TextSpan _compileUsername(BuildContext context, User user) => TextSpan(
        text: user.username ?? '',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      );
}

class AppBarDrawerFooter extends StatelessWidget {
  const AppBarDrawerFooter({super.key});

  @override
  Widget build(BuildContext context) => Consumer<ApiAuth>(
      builder: (context, apiAuth, _) => apiAuth.hasToken
          ? ListTile(
              title: Text(l(context).menuLogout),
              onTap: () => logout(context),
            )
          : const SizedBox.shrink());
}
