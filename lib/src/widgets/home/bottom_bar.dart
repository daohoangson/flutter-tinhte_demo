import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/forum_list.dart';
import 'package:the_app/src/screens/menu.dart';
import 'package:the_app/src/screens/search/thread.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback? onHomeTap;

  const HomeBottomBar({Key? key, this.onHomeTap}) : super(key: key);

  @override
  Widget build(BuildContext context) => BottomAppBar(
        child: Row(
          children: <Widget>[
            Expanded(
              child: _BottomBarItem(
                icon: Icon(FontAwesomeIcons.house),
                onTap: onHomeTap,
                tooltip: l(context).home,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icon(FontAwesomeIcons.magnifyingGlass),
                onTap: () => showSearch(
                    context: context, delegate: ThreadSearchDelegate()),
                tooltip: l(context).search,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icon(FontAwesomeIcons.rectangleList),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ForumListScreen(),
                )),
                tooltip: l(context).forums,
              ),
            ),
            Expanded(
              child: _BottomBarItem(
                icon: Icon(FontAwesomeIcons.bars),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => MenuScreen(),
                )),
                tooltip: l(context).menu,
              ),
            ),
          ],
          mainAxisSize: MainAxisSize.max,
        ),
        shape: CircularNotchedRectangle(),
      );
}

class _BottomBarItem extends StatelessWidget {
  final Widget? icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _BottomBarItem({
    Key? key,
    this.icon,
    this.onTap,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => InkWell(
        child: Padding(
          child: Column(
            children: <Widget>[
              Padding(
                child: icon,
                padding: const EdgeInsets.all(4),
              ),
              Text(
                tooltip,
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          padding: const EdgeInsets.all(4),
        ),
        onTap: onTap,
      );
}
