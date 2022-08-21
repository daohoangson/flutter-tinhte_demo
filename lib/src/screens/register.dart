import 'package:flutter/material.dart';
import 'package:the_api/api.dart';
import 'package:the_api/oauth_token.dart';
import 'package:the_app/src/api.dart';
import 'package:the_app/src/config.dart';
import 'package:the_app/src/intl.dart';
import 'package:the_app/src/screens/login.dart';
import 'package:the_app/src/widgets/html.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(l(context).register)),
        body: const RegisterForm(),
      );
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterForm> {
  final focusNodeEmail = FocusNode();
  final focusNodePassword = FocusNode();
  final focusNodeAgreed = FocusNode();
  final formKey = GlobalKey<FormState>();

  bool _isRegistering = false;

  String _username = '';
  String? _usernameError;
  String _email = '';
  String? _emailError;
  String _password = '';
  bool _agreed = false;

  @override
  void dispose() {
    focusNodeEmail.dispose();
    focusNodePassword.dispose();
    focusNodeAgreed.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: _buildFields(),
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
                onPressed: _isRegistering
                    ? null
                    : () => Navigator.of(context)
                        .pushReplacement(LoginScreenRoute()),
                child: Text(l(context).login),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: !_agreed || _isRegistering ? null : _register,
                child: Text(l(context).register),
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
        focusNode: focusNodePassword,
        initialValue: _password,
        obscureText: true,
        onFieldSubmitted: (_) => focusNodeAgreed.requestFocus(),
        onSaved: (value) => _password = value!,
        validator: (value) {
          final password = (value ?? '').trim();
          if (password.isEmpty) {
            return l(context).registerErrorPasswordIsEmpty;
          }

          return null;
        },
      );

  Widget _buildUserEmail() => TextFormField(
      decoration: InputDecoration(
        labelText: l(context).registerEmail,
        errorText: _emailError,
      ),
      focusNode: focusNodeEmail,
      initialValue: _email,
      keyboardType: TextInputType.emailAddress,
      onFieldSubmitted: (_) => focusNodePassword.requestFocus(),
      onSaved: (value) => _email = value!,
      validator: (value) {
        final email = (value ?? '').trim();
        if (email.isEmpty) {
          return l(context).registerErrorEmailIsEmpty;
        }

        return null;
      });

  Widget _buildUsername() => TextFormField(
      autofocus: true,
      decoration: InputDecoration(
        labelText: l(context).loginUsername,
        errorText: _usernameError,
      ),
      initialValue: _username,
      keyboardType: TextInputType.name,
      onFieldSubmitted: (_) => focusNodeEmail.requestFocus(),
      onSaved: (value) => _username = value!,
      validator: (value) {
        final username = (value ?? '').trim();
        if (username.isEmpty) {
          return l(context).registerErrorUsernameIsEmpty;
        }

        return null;
      });

  Widget _buildAgreed() => InkWell(
        canRequestFocus: false,
        child: Row(
          children: [
            Checkbox(
              focusNode: focusNodeAgreed,
              onChanged: (value) => setState(() => _agreed = value == true),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: _agreed,
            ),
            Expanded(
              child: TinhteHtmlWidget(
                l(context).registerAgreeCheckboxHtml(
                  config.linkPrivacyPolicy,
                  config.linkTos,
                ),
                textPadding: 0,
              ),
            ),
          ],
        ),
        onTap: () => setState(() => _agreed = !_agreed),
      );

  void _register() {
    if (_isRegistering) return;

    setState(() {
      _usernameError = null;
      _emailError = null;
    });

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    setState(() => _isRegistering = true);

    final api = ApiAuth.of(context, listen: false).api;
    api
        .postJson(
          'users',
          bodyFields: {
            'client_id': api.clientId,
            'username': _username,
            'user_email': _email,
            'password': _password,
          },
        )
        .then(_onJson)
        .catchError(_showError)
        .whenComplete(() => setState(() => _isRegistering = false));
  }

  void _onJson(json) {
    if (!mounted || json == null || json is! Map) return;

    final map = json;
    if (!map.containsKey('token')) {
      return _showError(l(context).registerErrorNoAccessToken);
    }

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
            setState(() => _usernameError = e.value);
            break;
          case 'email':
            setState(() => _emailError = e.value);
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
