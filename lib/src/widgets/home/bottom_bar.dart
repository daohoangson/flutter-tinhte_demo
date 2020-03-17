import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tinhte_demo/src/screens/search/thread.dart';
import 'package:tinhte_demo/src/screens/forum_list.dart';
import 'package:tinhte_demo/src/screens/menu.dart';
import 'package:tinhte_demo/src/screens/my_feed.dart';

class HomeBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.newspaper),
            title: Text('My Feed'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.listAlt),
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MyFeedScreen(),
              ));
              break;
            case 2:
              showSearch(
                context: context,
                delegate: ThreadSearchDelegate(),
              );
              break;
            case 3:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ForumListScreen(),
              ));
              break;
            case 4:
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MenuScreen(),
              ));
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
      );
}
