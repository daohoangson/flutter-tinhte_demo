import 'package:flutter/widgets.dart';

import 'package:tinhte_api/api.dart';

class ApiInheritedWidget extends InheritedWidget {
  final Api api;

  ApiInheritedWidget({
    Key key,
    @required this.api,
    @required Widget child,
  }) : super(key: key, child: child);

  static ApiInheritedWidget of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ApiInheritedWidget);
  }

  @override
  bool updateShouldNotify(ApiInheritedWidget old) => old.api != api;
}
