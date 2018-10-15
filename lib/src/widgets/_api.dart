import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/oauth_token.dart';

import '../constants.dart';

class ApiInheritedWidget extends StatefulWidget {
  final Api api;
  final Widget child;

  ApiInheritedWidget({
    Key key,
    @required this.api,
    @required this.child,
  }) : super(key: key);

  @override
  State<ApiInheritedWidget> createState() => ApiData();

  static ApiData of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(_Inherited) as _Inherited).data;
}

class ApiData extends State<ApiInheritedWidget> {
  Api get api => widget.api;

  OauthToken _token;
  OauthToken get token => _token;
  set token(OauthToken value) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString(kPrefKeyTokenAccessToken, value?.accessToken);
      prefs.setString(kPrefKeyTokenClientId, api.clientId);
      prefs.setInt(kPrefKeyTokenExpiresAtMillisecondsSinceEpoch,
          value?.expiresAt?.millisecondsSinceEpoch);
      prefs.setString(kPrefKeyTokenRefreshToken, value?.refreshToken);
      prefs.setString(kPrefKeyTokenScope, value?.scope);
      prefs.setInt(kPrefKeyTokenUserId, value?.userId);
      debugPrint("Saved token ${token?.accessToken}," +
          " expires at ${token?.expiresAt}");
    });

    setState(() => _token = value);
  }

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final clientId = prefs.getString(kPrefKeyTokenClientId);
      if (clientId != api.clientId) return;

      final accessToken = prefs.getString(kPrefKeyTokenAccessToken);
      final expiresAtMillisecondsSinceEpoch =
          prefs.getInt(kPrefKeyTokenExpiresAtMillisecondsSinceEpoch) ?? 0;
      final refreshToken = prefs.getString(kPrefKeyTokenRefreshToken);
      final scope = prefs.getString(kPrefKeyTokenScope);
      final userId = prefs.getInt(kPrefKeyTokenUserId);
      if (accessToken?.isNotEmpty != true ||
          expiresAtMillisecondsSinceEpoch < 1 ||
          refreshToken?.isNotEmpty != true) return;

      final expiresIn = ((expiresAtMillisecondsSinceEpoch -
                  DateTime.now().millisecondsSinceEpoch) /
              1000)
          .floor();
      final token =
          OauthToken(accessToken, expiresIn, refreshToken, scope, userId);
      debugPrint("Restored token $accessToken, expires in $expiresIn");
      setState(() => _token = token);
    });
  }

  @override
  Widget build(BuildContext context) =>
      _Inherited(child: widget.child, data: this);
}

class _Inherited extends InheritedWidget {
  final ApiData data;

  _Inherited({
    Widget child,
    this.data,
    Key key,
  }) : super(child: child, key: key);

  @override
  bool updateShouldNotify(_Inherited old) => true;
}
