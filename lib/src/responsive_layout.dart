import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinhte_api/navigation.dart' as navigation;
import 'package:tinhte_api/node.dart' as node;

import 'screens/home.dart';
import 'screens/login.dart';
import 'widgets/app_bar.dart';
import 'widgets/navigation.dart';
import 'push_notification.dart';

const _kRouteHome = 'home';
const _kNarrowWidth = 1000;

class ResponsiveLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  final primaryNavKey = GlobalKey<NavigatorState>();
  final narrowKey = GlobalKey<ScaffoldState>();
  final wideKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext _) => PushNotificationApp(
        child: WillPopScope(
          child: LayoutBuilder(
            builder: (_, bc) {
              final isNarrow = bc.maxWidth < _kNarrowWidth;
              final child = isNarrow ? buildNarrow() : buildWide();
              final rs = ResponsiveState(
                narrowKey: isNarrow ? narrowKey : null,
              );

              return Provider<ResponsiveState>.value(child: child, value: rs);
            },
          ),
          onWillPop: () async {
            final primary = primaryNavKey.currentState;
            final primaryCanPop = primary?.canPop() == true;
            if (!primaryCanPop) return true;

            primary.pop();
            return false;
          },
        ),
        primaryNavKey: primaryNavKey,
      );

  Widget buildNarrow() => Scaffold(
        body: Container(child: _buildPrimaryNavigator()),
        drawer: Drawer(
          child: _buildSidebarNavigator(
            scaffoldKey: narrowKey,
          ),
        ),
        key: narrowKey,
      );

  Widget buildWide() => Scaffold(
        body: Row(
          children: <Widget>[
            Flexible(flex: 1, child: _buildSidebarNavigator()),
            Flexible(flex: 3, child: _buildPrimaryNavigator()),
          ],
        ),
        key: wideKey,
      );

  Widget _buildPrimaryNavigator() => Navigator(
        key: primaryNavKey,
        onGenerateRoute: (_) => HomeScreenRoute(),
      );

  Widget _buildSidebarNavigator({GlobalKey<ScaffoldState> scaffoldKey}) =>
      _SidebarNavigator(
        scaffoldKey,
        primaryNavKey,
        (route) {
          switch (route.name) {
            case '/':
              return NavigationRoute((_) => NavigationWidget(
                    footer: AppBarDrawerFooter(),
                    header: AppBarDrawerHeader(),
                    initialElements: [
                      navigation.Element(0, _kRouteHome)
                        ..node = (node.Category(0)..categoryTitle = "Home"),
                    ],
                    path: 'navigation?parent=0',
                  ));
            case _kRouteHome:
              return HomeScreenRoute();
          }
        },
      );
}

class ResponsiveState {
  final GlobalKey<ScaffoldState> _narrowKey;

  ResponsiveState({GlobalKey<ScaffoldState> narrowKey})
      : _narrowKey = narrowKey;

  bool hasDrawer() => _narrowKey != null;

  void openDrawer() => _narrowKey?.currentState?.openDrawer();
}

class _SidebarNavigator extends Navigator {
  final GlobalKey<NavigatorState> primaryNavKey;
  final GlobalKey<ScaffoldState> scaffoldKey;

  _SidebarNavigator(
    this.scaffoldKey,
    this.primaryNavKey,
    RouteFactory onGenerateRoute,
  ) : super(onGenerateRoute: onGenerateRoute);

  @override
  NavigatorState createState() => _SidebarNavigatorState();
}

class _SidebarNavigatorState extends NavigatorState {
  @override
  Future<T> push<T extends Object>(Route<T> route) {
    if (route is NavigationRoute) {
      return super.push(route);
    }

    final scaffold = (widget as _SidebarNavigator).scaffoldKey?.currentState;
    if (scaffold == null && route is LoginScreenRoute) {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
              child: SizedBox(child: LoginForm(), height: 400, width: 400),
            ),
      );
    }

    final f = _pushPrimary(route);

    if (scaffold?.isDrawerOpen == true) {
      Navigator.of(scaffold.context).pop();
    }

    return f;
  }

  Future<T> _pushPrimary<T extends Object>(Route<T> route) {
    final primary = (widget as _SidebarNavigator).primaryNavKey.currentState;

    if (route is HomeScreenRoute) {
      primary?.popUntil((r) => r.isFirst);
      return Future.value(null);
    }

    return Future.value(primary?.pushAndRemoveUntil(route, (r) => r.isFirst));
  }
}
