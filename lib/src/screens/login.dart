import 'package:apple_sign_in/apple_sign_in.dart' as apple;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';

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

  LoginAssociatable _associatable;
  LoginTfa _tfa;
  bool _canLoginApple = false;
  bool _isLoggingIn = false;

  String username;
  String password;
  String tfaCode;

  _LoginFormState();

  @override
  void initState() {
    super.initState();

    if (config.loginWithApple)
      apple.AppleSignIn.isAvailable()
          .then((ok) => ok ? setState(() => _canLoginApple = true) : null);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Form(
          key: formKey,
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: _tfa != null
                  ? _buildFieldsTfa()
                  : _associatable != null
                      ? _buildFieldsAssociate()
                      : _buildFieldsLogin(),
            ),
          ),
        ),
      );

  List<Widget> _buildFieldsAssociate() => [
        Text(l(context).loginAssociateEnterPassword),
        _buildInputPadding(TextFormField(
          decoration: InputDecoration(labelText: l(context).loginUsername),
          enabled: false,
          initialValue: _associatable.username,
          key: ObjectKey(_associatable),
        )),
        _buildInputPadding(_buildPassword(autofocus: true)),
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                child: Text(lm(context).cancelButtonLabel),
                onPressed: _isLoggingIn
                    ? null
                    : () => setState(() => _associatable = null),
              ),
            ),
            Expanded(
              child: RaisedButton(
                child: Text(l(context).loginAssociate),
                onPressed: _isLoggingIn ? null : _associate,
              ),
            ),
          ],
        ),
      ];

  List<Widget> _buildFieldsLogin() => [
        _buildInputPadding(_buildUsername()),
        _buildInputPadding(_buildPassword()),
        RaisedButton(
          child: Text(lm(context).continueButtonLabel),
          onPressed: _isLoggingIn ? null : _login,
        ),
        config.loginWithFacebook
            ? FacebookSignInButton(
                onPressed: _isLoggingIn ? null : _loginFacebook,
                text: l(context).loginWithFacebook,
              )
            : const SizedBox.shrink(),
        config.loginWithGoogle
            ? GoogleSignInButton(
                darkMode: true,
                onPressed: _isLoggingIn ? null : _loginGoogle,
                text: l(context).loginWithGoogle,
              )
            : const SizedBox.shrink(),
        _canLoginApple
            ? AppleSignInButton(
                onPressed: _isLoggingIn ? null : _loginApple,
                style: AppleButtonStyle.black,
                text: l(context).loginWithApple,
              )
            : const SizedBox.shrink(),
      ];

  List<Widget> _buildFieldsTfa() => [
        Text(l(context).loginTfaMethodPleaseChooseOne),
      ]
        ..addAll(_tfa.providers
            .map((provider) => RaisedButton.icon(
                  icon: !_isLoggingIn && _tfa.triggeredProvider == provider
                      ? Icon(
                          FontAwesomeIcons.check,
                          color: Theme.of(context).indicatorColor,
                        )
                      : const SizedBox.shrink(),
                  label: Text(provider == 'backup'
                      ? l(context).loginTfaMethodBackup
                      : provider == 'email'
                          ? l(context).loginTfaMethodEmail
                          : provider == 'totp'
                              ? l(context).loginTfaMethodTotp
                              : provider),
                  onPressed: _isLoggingIn ? null : () => _tfaTrigger(provider),
                ))
            .toList(growable: false))
        ..add(_tfa.triggeredProvider != null
            ? _buildInputPadding(_buildTfaCode())
            : const SizedBox.shrink())
        ..add(_tfa.triggeredProvider != null
            ? Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Text(lm(context).cancelButtonLabel),
                      onPressed: _isLoggingIn
                          ? null
                          : () => setState(() => _tfa = null),
                    ),
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Text(l(context).loginTfaVerify),
                      onPressed: _isLoggingIn ? null : _tfaVerify,
                    ),
                  ),
                ],
              )
            : FlatButton(
                child: Text(lm(context).cancelButtonLabel),
                onPressed:
                    _isLoggingIn ? null : () => setState(() => _tfa = null),
              ));

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: child,
      );

  Widget _buildPassword({bool autofocus = false}) => TextFormField(
        autofillHints: [AutofillHints.password],
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: l(context).loginPasswordHint,
          labelText: l(context).loginPassword,
        ),
        initialValue: password,
        obscureText: true,
        onSaved: (value) => password = value,
        validator: (password) {
          if (password.isEmpty) {
            return l(context).loginErrorPasswordIsEmpty;
          }

          return null;
        },
      );

  Widget _buildUsername() => TextFormField(
      autofillHints: [AutofillHints.email, AutofillHints.username],
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).loginUsernameHint,
        labelText: l(context).loginUsernameOrEmail,
      ),
      initialValue: username,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => username = value,
      validator: (username) {
        if (username.isEmpty) {
          return l(context).loginErrorUsernameIsEmpty;
        }

        return null;
      });

  Widget _buildTfaCode() => TextFormField(
      autofocus: true,
      keyboardType: TextInputType.number,
      onSaved: (value) => tfaCode = value,
      validator: (tfaCode) {
        if (tfaCode.isEmpty) {
          return l(context).loginTfaErrorCodeIsEmpty;
        }

        return null;
      });

  void _associate() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    final api = apiAuth.api;

    loginAssociate(api, _associatable, password)
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _login() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    login(apiAuth.api, username, password)
        .then((result) => _onResult(apiAuth, result))
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
              final _l = l(context);
              return Future.error(_l.loginErrorCancelled(_l.loginWithApple));
            case apple.AuthorizationStatus.error:
              return Future.error(result.error.localizedDescription);
          }

          return Future.error(result.status.toString());
        })
        .then((appleIdCredential) => loginExternal(api, ObtainMethod.Apple, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'apple_token':
                  String.fromCharCodes(appleIdCredential.identityToken),
            }))
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
              final _l = l(context);
              return Future.error(_l.loginErrorCancelled(_l.loginWithFacebook));
            case FacebookLoginStatus.error:
              return Future.error(result.errorMessage);
          }

          return Future.error(result.status.toString());
        })
        .then((facebookToken) => loginExternal(api, ObtainMethod.Facebook, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'facebook_token': facebookToken,
            }))
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
            return Future.error(l(context).loginGoogleErrorAccountIsNull);
          }

          return account.authentication;
        })
        .then<String>((auth) {
          // the server supports both kind of tokens
          final googleToken = auth?.idToken ?? auth?.accessToken;
          if (googleToken.isNotEmpty != true) {
            return Future.error(l(context).loginGoogleErrorTokenIsEmpty);
          }

          return googleToken;
        })
        .then((googleToken) => loginExternal(api, ObtainMethod.Google, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'google_token': googleToken,
            }))
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _onResult(ApiAuth apiAuth, LoginResult result) {
    if (!mounted || result == null) return;

    if (result.token != null) {
      apiAuth.setToken(result.token);
      Navigator.pop(context, true);
      return;
    }

    if (result.associatable != null)
      setState(() => _associatable = result.associatable);

    if (result.tfa != null) setState(() => _tfa = result.tfa);
  }

  void _showError(BuildContext context, error) =>
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(error is ApiError ? error.message : "$error")));

  void _tfaTrigger(String provider) {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    loginTfa(apiAuth.api, _tfa, provider, trigger: true)
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _tfaVerify() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final apiAuth = ApiAuth.of(context, listen: false);
    loginTfa(apiAuth.api, _tfa, _tfa.triggeredProvider, code: tfaCode)
        .then((result) => _onResult(apiAuth, result))
        .catchError((e) => _showError(context, e))
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }
}

class LoginScreenRoute extends MaterialPageRoute {
  LoginScreenRoute()
      : super(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text(l(context).login)),
            body: LoginForm(),
          ),
        );
}
