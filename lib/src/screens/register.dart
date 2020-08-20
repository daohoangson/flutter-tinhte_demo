import 'package:flutter/material.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/intl.dart';

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
        RaisedButton(
          child: Text(lm(context).continueButtonLabel),
          onPressed: _isRegistering ? null : _register,
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

  void _register() {
    if (_isRegistering) return;

    final form = formKey.currentState;
    if (form?.validate() != true) return;
    form.save();

    setState(() {
      usernameError = null;
      emailError = null;

      _isRegistering = true;
    });

    final apiAuth = ApiAuth.of(context, listen: false);
    final api = apiAuth.api;
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
        .then((result) => _onResult(apiAuth, result))
        .catchError(_showError)
        .whenComplete(() => setState(() => _isRegistering = false));
  }

  void _onResult(ApiAuth apiAuth, json) {
    if (!mounted || json == null || json is! Map) return;

    final map = json as Map;
    if (!map.containsKey('token'))
      return _showError(l(context).registerErrorNoAccessToken);

    apiAuth.setToken(OauthToken.fromJson(map['token']));
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
    Scaffold.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.redAccent, content: Text(content)));
  }
}
