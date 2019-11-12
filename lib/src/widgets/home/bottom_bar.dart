import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../screens/search/thread.dart';
import '../../screens/forum_list.dart';
import '../../screens/menu.dart';

class HomeBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.newspaper),
            title: Text('Forums'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bars),
            title: Text('Menu'),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              showSearch(
                context: context,
                delegate: ThreadSearchDelegate(),
              );
              break;
            case 2:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ForumListScreen(),
              ));
              break;
            case 3:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MenuScreen(),
              ));
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
      );
}
