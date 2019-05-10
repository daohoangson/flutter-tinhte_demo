import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/oauth_token.dart';

import '../api.dart';

final _facebookLogin = FacebookLogin();

final _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

void logout(BuildContext context) {
  final apiData = ApiData.of(context);
  final token = apiData.token;

  apiData.setToken(null);

  if (token?.obtainMethod == ObtainMethod.Google) {
    _googleSignIn.signOut();
  }
}

Future<dynamic> pushLoginScreen(BuildContext context) =>
    Navigator.push(context, LoginScreenRoute());

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;

  String username;
  String password;

  _LoginFormState({this.username = '', this.password = ''});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) => Form(
              key: formKey,
              child: _buildBox(
                box,
                <Widget>[
                  _buildInputPadding(_buildUsername()),
                  _buildInputPadding(_buildPassword()),
                  _buildButton('Submit', _login),
                  _buildButton('Login with Facebook', _loginFacebook),
                  _buildButton('Login with Google', _loginGoogle),
                ],
              ),
            ),
      );

  Widget _buildBox(BoxConstraints box, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: box.biggest.shortestSide,
            width: box.biggest.shortestSide,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: children,
            ),
          ),
        ],
      );

  Widget _buildButton(String text, VoidCallback onPressed) => RaisedButton(
        child: Text(text),
        onPressed: _isLoggingIn ? null : onPressed,
      );

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: child,
      );

  Widget _buildPassword() => TextFormField(
        decoration: InputDecoration(
          hintText: 'hunter2',
          labelText: 'Password',
        ),
        initialValue: password,
        obscureText: true,
        onSaved: (value) => password = value,
        validator: (password) {
          if (password.isEmpty) {
            return 'Please enter your password to login';
          }

          return null;
        },
      );

  Widget _buildUsername() => TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'keyboard_warrior',
        labelText: 'Username / email',
      ),
      initialValue: username,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => username = value,
      validator: (username) {
        if (username.isEmpty) {
          return 'Please enter your username or email';
        }

        return null;
      });

  void _login() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (!form.validate()) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final apiData = ApiData.of(context);
    apiData.api
        .login(username, password)
        .then((token) => _loginOnToken(apiData, token))
        .catchError((e) => _showErrorDialog)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginFacebook() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiData = ApiData.of(context);
    final api = apiData.api;

    _facebookLogin
        .logInWithReadPermissions(['email'])
        .then<String>((result) {
          switch (result.status) {
            case FacebookLoginStatus.loggedIn:
              return result.accessToken.token;
            case FacebookLoginStatus.cancelledByUser:
              return Future.error('Login with Facebook has been cancelled.');
            case FacebookLoginStatus.error:
              return Future.error(result.errorMessage);
          }
        })
        .then((facebookToken) =>
            api.postJson('oauth/token/facebook', bodyFields: {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'facebook_token': facebookToken,
            }))
        .then<OauthToken>(
            (json) => _loginOnExternalJson(api, ObtainMethod.Facebook, json))
        .then((token) => _loginOnToken(apiData, token))
        .catchError(_showErrorDialog)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginGoogle() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiData = ApiData.of(context);
    final api = apiData.api;

    _googleSignIn
        .signIn()
        .then<GoogleSignInAuthentication>((account) {
          if (account == null) {
            return Future.error('Cannot get Google account information.');
          }

          return account.authentication;
        })
        .then<String>((auth) {
          // the server supports both kind of tokens
          final googleToken = auth?.idToken ?? auth?.accessToken;
          if (googleToken.isNotEmpty != true) {
            return Future.error('Cannot get Google authentication info.');
          }

          return googleToken;
        })
        .then((googleToken) => api.postJson('oauth/token/google', bodyFields: {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'google_token': googleToken,
            }))
        .then<OauthToken>(
            (json) => _loginOnExternalJson(api, ObtainMethod.Google, json))
        .then((token) => _loginOnToken(apiData, token))
        .catchError(_showErrorDialog)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  Future<OauthToken> _loginOnExternalJson(
      Api api, ObtainMethod obtainMethod, json) async {
    if (!mounted) return null;

    if (json is! Map) {
      return Future.error('Unexpected response from server.');
    }
    final jsonMap = json as Map;

    if (jsonMap.containsKey('message')) {
      if (jsonMap.containsKey('user_data')) {
        return _tryAutoRegister(
          api,
          message: jsonMap['message'],
          obtainMethod: obtainMethod,
          userData: jsonMap['user_data'],
        );
      }

      return Future.error(jsonMap['message']);
    }

    if (jsonMap.containsKey('errors')) {
      return Future.error((jsonMap['errors'] as List<String>).join(', '));
    }

    if (!jsonMap.containsKey('access_token')) {
      return Future.error('Cannot login with ${obtainMethod.toString()}.');
    }

    return OauthToken.fromJson(ObtainMethod.Google, jsonMap);
  }

  _loginOnToken(ApiData apiData, OauthToken token) {
    if (!mounted || token == null) return;

    apiData.setToken(token);
    Navigator.pop(context, true);
  }

  Future<OauthToken> _tryAutoRegister(
    Api api, {
    @required String message,
    @required ObtainMethod obtainMethod,
    @required Map<String, dynamic> userData,
  }) {
    assert(message != null);
    assert(obtainMethod != null);
    assert(userData != null);

    if (!userData.containsKey('extra_data') ||
        !userData.containsKey('extra_timestamp') ||
        !userData.containsKey('user_email')) {
      return Future.error(message);
    }

    final bodyFields = {
      'client_id': api.clientId,
      'client_secret': api.clientSecret,
    };
    for (final e in userData.entries) {
      try {
        bodyFields[e.key] = e.value.toString();
      } catch (e) {
        print(e);
      }
    }

    if (!bodyFields.containsKey('username')) {
      final email = userData['user_email'] as String;
      final emailName = email.replaceAll(RegExp(r'@.+$'), '');
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      bodyFields['username'] = "${emailName}_$timestamp";
    }

    return api
        .postJson('users', bodyFields: bodyFields)
        .then<OauthToken>((json) {
      if (json is! Map) {
        return Future.error('Unexpected response from server.');
      }

      final jsonMap = json as Map;
      if (!jsonMap.containsKey('token')) {
        print(jsonMap);
        return Future.error('Cannot register new user account.');
      }

      return OauthToken.fromJson(obtainMethod, jsonMap['token']);
    });
  }

  void _showErrorDialog(error) => showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Login error'),
              content: Text(error is ApiError ? error.message : "$error"),
            ),
      );
}

class LoginScreenRoute extends MaterialPageRoute {
  LoginScreenRoute()
      : super(
          builder: (_) => Scaffold(
                appBar: AppBar(title: Text('Login')),
                body: LoginForm(),
              ),
        );
}
