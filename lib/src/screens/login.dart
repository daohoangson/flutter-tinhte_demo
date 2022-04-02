import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:the_api/api.dart';
import 'package:the_api/login_result.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/abstracts/apple_sign_in.dart' as apple_sign_in;
import 'package:the_app/src/abstracts/facebook_log_in.dart' as facebook_log_in;
import 'package:the_app/src/abstracts/google_sign_in.dart' as google_sign_in;
import 'package:the_app/src/screens/register.dart';
import 'package:the_app/src/widgets/sign_in_button.dart';

void logout(BuildContext context) {
  final apiData = ApiAuth.of(context, listen: false);
  final token = apiData.token;

  apiData.setToken(null);

  switch (token?.obtainMethod) {
    case ObtainMethod.facebook:
      facebook_log_in.logOut();
      break;
    case ObtainMethod.google:
      google_sign_in.signOut();
      break;
    default:
    // intentionally left empty
  }
}

class LoginForm extends StatefulWidget {
  LoginForm({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final focusNodePassword = FocusNode();
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
      apple_sign_in.isSupported.then((ok) {
        if (!ok || !mounted) return;
        setState(() => _canLoginApple = true);
      });
  }

  @override
  void dispose() {
    focusNodePassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: AutofillGroup(
          child: ListView(
            children: _tfa != null
                ? _buildFieldsTfa()
                : _associatable != null
                    ? _buildFieldsAssociate()
                    : _buildFieldsLogin(),
            padding: const EdgeInsets.all(20.0),
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
              child: TextButton(
                child: Text(lm(context).cancelButtonLabel),
                onPressed: _isLoggingIn
                    ? null
                    : () => setState(() => _associatable = null),
              ),
            ),
            Expanded(
              child: ElevatedButton(
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
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                child: Text(l(context).register),
                onPressed: _isLoggingIn
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => RegisterScreen())),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                child: Text(l(context).login),
                onPressed: _isLoggingIn ? null : _login,
              ),
            ),
          ],
        ),
        if (_canLoginApple)
          SignInButton.apple(
            onPressed: _loginApple,
            text: l(context).loginWithApple,
          ),
        if (config.loginWithFacebook)
          SignInButton.facebook(
            onPressed: _loginFacebook,
            text: l(context).loginWithFacebook,
          ),
        if (config.loginWithGoogle && google_sign_in.isSupported)
          SignInButton.google(
            onPressed: _loginGoogle,
            text: l(context).loginWithGoogle,
          ),
      ];

  List<Widget> _buildFieldsTfa() => [
        Text(l(context).loginTfaMethodPleaseChooseOne),
      ]
        ..addAll(_tfa.providers
            .map((provider) => ElevatedButton.icon(
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
                    child: TextButton(
                      child: Text(lm(context).cancelButtonLabel),
                      onPressed: _isLoggingIn
                          ? null
                          : () => setState(() => _tfa = null),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text(l(context).loginTfaVerify),
                      onPressed: _isLoggingIn ? null : _tfaVerify,
                    ),
                  ),
                ],
              )
            : TextButton(
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
        focusNode: focusNodePassword,
        initialValue: password,
        obscureText: true,
        onSaved: (value) => password = value,
        onFieldSubmitted: (_) => _login(),
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
      onFieldSubmitted: (_) => focusNodePassword.requestFocus(),
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

    final api = ApiAuth.of(context, listen: false).api;
    loginAssociate(api, _associatable, password)
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _login() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    login(api, username, password)
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginApple() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;

    apple_sign_in
        .signIn(context)
        .then((appleToken) => loginExternal(api, ObtainMethod.apple, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'apple_token': appleToken,
            }))
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginFacebook() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    facebook_log_in
        .logIn(context)
        .then((facebookToken) => loginExternal(api, ObtainMethod.facebook, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'facebook_token': facebookToken,
            }))
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _loginGoogle() {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    google_sign_in
        .signIn(context)
        .then((googleToken) => loginExternal(api, ObtainMethod.google, {
              'client_id': api.clientId,
              'client_secret': api.clientSecret,
              'google_token': googleToken,
            }))
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _onResult(LoginResult result) {
    if (!mounted || result == null) return;

    result.when(
      associatable: (v) => setState(() => _associatable = v),
      tfa: (v) => setState(() => _tfa = v),
      token: (v) {
        final apiAuth = ApiAuth.of(context, listen: false);
        apiAuth.setToken(v);
        Navigator.pop(context, true);
      },
    );
  }

  void _showError(error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text(error is ApiError ? error.message : "$error")));

  void _tfaTrigger(String provider) {
    if (_isLoggingIn) return;
    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    loginTfa(api, _tfa, provider, trigger: true)
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _tfaVerify() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    loginTfa(api, _tfa, _tfa.triggeredProvider, code: tfaCode)
        .then(_onResult)
        .catchError(_showError)
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
