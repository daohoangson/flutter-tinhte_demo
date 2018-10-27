import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tinhte_api/api.dart';
import 'package:tinhte_api/oauth_token.dart';

import '../api.dart';

final _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
  ],
);

void logout(State state) {
  final apiData = ApiData.of(state.context);
  final token = apiData.token;

  apiData.setToken(null);

  if (token.obtainMethod == ObtainMethod.Google) {
    _googleSignIn.signOut();
  }
}

Future<dynamic> pushLoginScreen(BuildContext context) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  bool _isLoggingIn = false;

  String username;
  String password;

  _LoginScreenState({this.username = '', this.password = ''});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sizeShorter = size.width > size.height ? size.height : size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: sizeShorter,
              width: sizeShorter,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: _buildUsername(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: _buildPassword(),
                  ),
                  RaisedButton(
                    child: Text('Submit'),
                    onPressed: _isLoggingIn ? null : _login,
                  ),
                  RaisedButton(
                    child: Text('Login with Google'),
                    onPressed: _isLoggingIn ? null : _loginGoogle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        hintText: 'cuhiep@tinhte.vn',
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
        .then((token) {
          apiData.setToken(token);

          if (!mounted) return;
          Navigator.pop(context, true);
        })
        .catchError((e) => _showErrorDialog)
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
        .then((idToken) => api.postJson('oauth/token/google', bodyFields: {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'google_token': idToken,
            }))
        .then((json) {
          if (!mounted) return false;

          if (json is! Map) {
            return Future.error('Unexpected response from server.');
          }
          final jsonMap = json as Map;

          if (jsonMap.containsKey('message')) {
            // TODO: register with extra_data?
            return Future.error(jsonMap['message']);
          }

          if (jsonMap.containsKey('errors')) {
            return Future.error((jsonMap['errors'] as List<String>).join(', '));
          }

          if (!jsonMap.containsKey('access_token')) {
            return Future.error('Cannot login with Google.');
          }

          final token = OauthToken.fromJson(ObtainMethod.Google, jsonMap);
          apiData.setToken(token);

          return Navigator.pop(context, true);
        })
        .catchError(_showErrorDialog)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _showErrorDialog(error) => showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Login error'),
              content: Text(error is ApiError ? error.message : "$error"),
            ),
      );
}
