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
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final focusNodePassword = FocusNode();
  final formKey = GlobalKey<FormState>();

  LoginAssociatable? _associatable;
  LoginTfa? _tfa;
  bool _isLoggingIn = false;

  String _username = '';
  String _password = '';
  String _tfaCode = '';

  _LoginFormState();

  @override
  void dispose() {
    focusNodePassword.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scopedTfa = _tfa;
    final scopedAssociatable = _associatable;

    return Form(
      key: formKey,
      child: AutofillGroup(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: scopedTfa != null
              ? _buildFieldsTfa(scopedTfa)
              : scopedAssociatable != null
                  ? _buildFieldsAssociate(scopedAssociatable)
                  : _buildFieldsLogin(),
        ),
      ),
    );
  }

  List<Widget> _buildFieldsAssociate(LoginAssociatable associatable) {
    return [
      Text(l(context).loginAssociateEnterPassword),
      _buildInputPadding(TextFormField(
        decoration: InputDecoration(labelText: l(context).loginUsername),
        enabled: false,
        initialValue: associatable.username,
        key: ObjectKey(associatable),
      )),
      _buildInputPadding(_buildPassword(autofocus: true)),
      Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: _isLoggingIn
                  ? null
                  : () => setState(() => _associatable = null),
              child: Text(lm(context).cancelButtonLabel),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoggingIn ? null : _associate,
              child: Text(l(context).loginAssociate),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildFieldsLogin() => [
        _buildInputPadding(_buildUsername()),
        _buildInputPadding(_buildPassword()),
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: _isLoggingIn
                    ? null
                    : () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                child: Text(l(context).register),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoggingIn ? null : _login,
                child: Text(l(context).login),
              ),
            ),
          ],
        ),
        if (config.loginWithApple && apple_sign_in.isSupported)
          SignInButton.apple(
            onPressed: _loginApple,
            text: l(context).loginWithApple,
          ),
        if (config.loginWithFacebook && facebook_log_in.isSupported)
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

  List<Widget> _buildFieldsTfa(LoginTfa tfa) {
    return [
      Text(l(context).loginTfaMethodPleaseChooseOne),
      ...tfa.providers
          .map((provider) => ElevatedButton.icon(
                icon: !_isLoggingIn && tfa.triggeredProvider == provider
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
          .toList(growable: false),
      tfa.triggeredProvider != null
          ? _buildInputPadding(_buildTfaCode())
          : const SizedBox.shrink(),
      tfa.triggeredProvider != null
          ? Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isLoggingIn ? null : () => setState(() => _tfa = null),
                    child: Text(lm(context).cancelButtonLabel),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoggingIn ? null : _tfaVerify,
                    child: Text(l(context).loginTfaVerify),
                  ),
                ),
              ],
            )
          : TextButton(
              onPressed:
                  _isLoggingIn ? null : () => setState(() => _tfa = null),
              child: Text(lm(context).cancelButtonLabel),
            ),
    ];
  }

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: child,
      );

  Widget _buildPassword({bool autofocus = false}) => TextFormField(
        autofillHints: const [AutofillHints.password],
        autofocus: autofocus,
        decoration: InputDecoration(
          hintText: l(context).loginPasswordHint,
          labelText: l(context).loginPassword,
        ),
        focusNode: focusNodePassword,
        initialValue: _password,
        obscureText: true,
        onSaved: (value) => _password = value!,
        onFieldSubmitted: (_) => _login(),
        validator: (value) {
          final password = (value ?? '').trim();
          if (password.isEmpty) {
            return l(context).loginErrorPasswordIsEmpty;
          }

          return null;
        },
      );

  Widget _buildUsername() => TextFormField(
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      autofocus: true,
      decoration: InputDecoration(
        hintText: l(context).loginUsernameHint,
        labelText: l(context).loginUsernameOrEmail,
      ),
      initialValue: _username,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => _username = value!,
      onFieldSubmitted: (_) => focusNodePassword.requestFocus(),
      validator: (value) {
        final username = (value ?? '').trim();
        if (username.isEmpty) {
          return l(context).loginErrorUsernameIsEmpty;
        }

        return null;
      });

  Widget _buildTfaCode() => TextFormField(
      autofocus: true,
      keyboardType: TextInputType.number,
      onSaved: (value) => _tfaCode = value!,
      validator: (value) {
        final tfaCode = (value ?? '').trim();
        if (tfaCode.isEmpty) {
          return l(context).loginTfaErrorCodeIsEmpty;
        }

        return null;
      });

  void _associate() {
    if (_isLoggingIn) return;

    final scopedAssociatable = _associatable;
    if (scopedAssociatable == null) return;

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    loginAssociate(api, scopedAssociatable, _password)
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _login() {
    if (_isLoggingIn) return;

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    login(api, _username, _password)
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
    if (!mounted) return;

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

    final scopedTfa = _tfa;
    if (scopedTfa == null) return;

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    loginTfa(api, scopedTfa, provider, trigger: true)
        .then(_onResult)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isLoggingIn = false));
  }

  void _tfaVerify() {
    if (_isLoggingIn) return;

    final scopedTfa = _tfa;
    if (scopedTfa == null) return;

    final tfaProvider = scopedTfa.triggeredProvider;
    if (tfaProvider == null) return;

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _isLoggingIn = true);

    final api = ApiAuth.of(context, listen: false).api;
    loginTfa(api, scopedTfa, tfaProvider, code: _tfaCode)
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
            body: const LoginForm(),
          ),
        );
}
