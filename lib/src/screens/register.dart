import 'package:flutter/material.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/login.dart';
import 'package:the_app/src/widgets/html.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(l(context).register)),
        body: RegisterForm(),
      );
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();

  bool _isRegistering = false;

  String username;
  String usernameError;
  String email;
  String emailError;
  String password;
  bool agreed = false;

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: ListView(
          children: _buildFields(),
          padding: const EdgeInsets.all(20.0),
        ),
      );

  List<Widget> _buildFields() => [
        _buildInputPadding(_buildUsername()),
        _buildInputPadding(_buildUserEmail()),
        _buildInputPadding(_buildPassword()),
        _buildAgreed(),
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                child: Text(l(context).login),
                onPressed: _isRegistering
                    ? null
                    : () => Navigator.of(context)
                        .pushReplacement(LoginScreenRoute()),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                child: Text(l(context).register),
                onPressed: !agreed || _isRegistering ? null : _register,
              ),
            ),
          ],
        ),
      ];

  Widget _buildInputPadding(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: child,
      );

  Widget _buildPassword() => TextFormField(
        decoration: InputDecoration(labelText: l(context).loginPassword),
        initialValue: password,
        obscureText: true,
        onSaved: (value) => password = value,
        validator: (password) {
          if (password.isEmpty) {
            return l(context).registerErrorPasswordIsEmpty;
          }

          return null;
        },
      );

  Widget _buildUserEmail() => TextFormField(
      decoration: InputDecoration(
        labelText: l(context).registerEmail,
        errorText: emailError,
      ),
      initialValue: email,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) => email = value,
      validator: (email) {
        if (email.isEmpty) {
          return l(context).registerErrorEmailIsEmpty;
        }

        return null;
      });

  Widget _buildUsername() => TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: l(context).loginUsername,
        errorText: usernameError,
      ),
      initialValue: username,
      keyboardType: TextInputType.name,
      onSaved: (value) => username = value,
      validator: (username) {
        if (username.isEmpty) {
          return l(context).registerErrorUsernameIsEmpty;
        }

        return null;
      });

  Widget _buildAgreed() => InkWell(
        child: Row(
          children: [
            Checkbox(
              onChanged: (value) => setState(() => agreed = value),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: agreed,
            ),
            Expanded(
              child: TinhteHtmlWidget(
                l(context).registerAgreeCheckboxHtml(
                  privacyPolicy: config.linkPrivacyPolicy,
                  terms: config.linkTos,
                ),
                textPadding: 0,
              ),
            ),
          ],
        ),
        onTap: () => setState(() => agreed = !agreed),
      );

  void _register() {
    if (_isRegistering) return;

    setState(() {
      usernameError = null;
      emailError = null;
    });

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() => _isRegistering = true);

    final api = ApiAuth.of(context, listen: false).api;
    api
        .postJson(
          'users',
          bodyFields: {
            'client_id': api.clientId,
            'username': username,
            'user_email': email,
            'password': password,
          },
        )
        .then(_onJson)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isRegistering = false));
  }

  void _onJson(json) {
    if (!mounted || json == null || json is! Map) return;

    final map = json as Map;
    if (!map.containsKey('token'))
      return _showError(l(context).registerErrorNoAccessToken);

    final apiAuth = ApiAuth.of(context, listen: false);
    apiAuth.setToken(OauthToken.fromJson(
      map['token'],
      ObtainMethod.usernamePassword,
    ));
    Navigator.pop(context, true);
  }

  void _showError(error) {
    var content = error is ApiError ? error.message : "$error";

    if (error is ApiErrorMapped) {
      content = '';

      final errors = error.errors;
      final unknownErrors = <String>[];
      for (final e in errors.entries) {
        switch (e.key) {
          case 'username':
            setState(() => usernameError = e.value);
            break;
          case 'email':
            setState(() => emailError = e.value);
            break;
          default:
            unknownErrors.add(e.value);
        }
      }

      content = unknownErrors.join(', ');
    }

    if (content.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(content)));
  }
}
