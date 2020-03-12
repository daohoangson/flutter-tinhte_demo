import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
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
  final apiData = ApiAuth.of(context, listen: false);
  final token = apiData.token;

  apiData.setToken(null);

  if (token?.obtainMethod == ObtainMethod.Google) {
    _googleSignIn.signOut();
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final formKey = GlobalKey<FormState>();

  bool _canLoginApple = false;
  bool _isLoggingIn = false;

  String username;
  String password;

  _LoginFormState({this.username = '', this.password = ''});

  @override
  void initState() {
    super.initState();

    apple.AppleSignIn.isAvailable()
        .then((ok) => ok ? setState(() => _canLoginApple = true) : null);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) => Form(
          key: formKey,
          child: _buildBox(
            box,
            <Widget>[
              _buildInputPadding(_buildUsername()),
              _buildInputPadding(_buildPassword()),
              RaisedButton(
                child: const Text('Submit'),
                onPressed: _isLoggingIn ? null : _login,
              ),
              FacebookSignInButton(
                onPressed: _isLoggingIn ? null : _loginFacebook,
                text: 'Sign in with Facebook',
              ),
              GoogleSignInButton(
                darkMode: true,
                onPressed: _isLoggingIn ? null : _loginGoogle,
              ),
              _canLoginApple
                  ? AppleSignInButton(
                      onPressed: _isLoggingIn ? null : _loginApple,
                      style: AppleButtonStyle.black,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );

  Widget _buildBox(BoxConstraints box, List<Widget> children) => ListView(
        padding: const EdgeInsets.all(20.0),
        children: children,
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
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    apiAuth.api
        .login(username, password)
        .then((token) => _onResult(apiAuth, _LoginResult.success(token)))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginApple() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    final api = apiAuth.api;
    final req = apple.AppleIdRequest(requestedScopes: [apple.Scope.email]);

    apple.AppleSignIn.performRequests([req])
        .then<apple.AppleIdCredential>((result) {
          switch (result.status) {
            case apple.AuthorizationStatus.authorized:
              return result.credential;
            case apple.AuthorizationStatus.cancelled:
              return Future.error('Login with Apple has been cancelled.');
            case apple.AuthorizationStatus.error:
              return Future.error(result.error.localizedDescription);
          }

          return Future.error(result.status.toString());
        })
        .then((appleIdCredential) =>
            api.postJson('oauth/token/apple', bodyFields: {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'apple_token':
                  String.fromCharCodes(appleIdCredential.identityToken),
            }))
        .then((json) => _onExternalJson(api, ObtainMethod.Apple, json))
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginFacebook() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    final api = apiAuth.api;

    _facebookLogin
        .logIn(['email'])
        .then<String>((result) {
          switch (result.status) {
            case FacebookLoginStatus.loggedIn:
              return result.accessToken.token;
            case FacebookLoginStatus.cancelledByUser:
              return Future.error('Login with Facebook has been cancelled.');
            case FacebookLoginStatus.error:
              return Future.error(result.errorMessage);
          }

          return Future.error(result.status.toString());
        })
        .then((facebookToken) =>
            api.postJson('oauth/token/facebook', bodyFields: {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'facebook_token': facebookToken,
            }))
        .then((json) => _onExternalJson(api, ObtainMethod.Facebook, json))
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginGoogle() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    final api = apiAuth.api;

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
        .then((json) => _onExternalJson(api, ObtainMethod.Google, json))
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  Future<_LoginResult> _onExternalJson(Api api, ObtainMethod om, json) async {
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
          obtainMethod: om,
          userData: jsonMap['user_data'],
        );
      }

      return Future.error(jsonMap['message']);
    }

    if (jsonMap.containsKey('errors')) {
      return Future.error((jsonMap['errors'] as List<String>).join(', '));
    }

    if (!jsonMap.containsKey('access_token')) {
      return Future.error('Cannot login with ${om.toString()}.');
    }

    return _LoginResult.success(OauthToken.fromJson(om, jsonMap));
  }

  _onResult(ApiAuth apiAuth, _LoginResult result) {
    if (!mounted || result == null) return;

    if (result.token != null) {
      apiAuth.setToken(result.token);
      Navigator.pop(context, true);
    }
  }

  Future<_LoginResult> _tryAutoRegister(
    Api api, {
    @required String message,
    @required ObtainMethod obtainMethod,
    @required Map<String, dynamic> userData,
  }) {
    assert(message != null);
    assert(obtainMethod != null);
    assert(userData != null);

    if (!userData.containsKey('extra_data') ||
        !userData.containsKey('extra_timestamp')) {
      return Future.error(message);
    }

    final bodyFields = {
      'client_id': api.clientId,
      'client_secret': api.clientSecret,
    };
    userData.entries
        .where((e) => e.value is String)
        .forEach((e) => bodyFields[e.key] = e.value);

    if (!bodyFields.containsKey('username') &&
        userData.containsKey('user_email')) {
      final email = userData['user_email'] as String;
      final emailName = email.replaceAll(RegExp(r'@.+$'), '');
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      bodyFields['username'] = "${emailName}_$timestamp";
    }

    // only perform auto register if an `username` is available
    if (!bodyFields.containsKey('username')) return Future.error(message);

    return api.postJson('users', bodyFields: bodyFields).then((json) {
      if (json is! Map) {
        return Future.error('Unexpected response from server.');
      }

      final jsonMap = json as Map;
      if (!jsonMap.containsKey('token')) {
        print(jsonMap);
        return Future.error('Cannot register new user account.');
      }

      final token = OauthToken.fromJson(obtainMethod, jsonMap['token']);
      return _LoginResult.success(token);
    });
  }

  void _showError(BuildContext context, error) =>
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(error is ApiError ? error.message : "$error")));
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

class _LoginResult {
  final OauthToken token;

  _LoginResult.success(this.token);
}
