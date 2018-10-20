import 'package:flutter/material.dart';

import '../widgets/_api.dart';

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
  final _formKey = GlobalKey<FormState>();

  bool isLoggingIn = false;

  String username;
  String password;

  _LoginScreenState({this.username = '', this.password = ''});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sizeShorter = size.width > size.height ? size.height : size.width;
    final textStyle = TextStyle(
      fontSize: 22.0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
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
                    child: TextFormField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'cuhiep@tinhte.vn',
                        labelText: 'Username / email',
                      ),
                      initialValue: username,
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => username = value,
                      style: textStyle,
                      validator: (username) {
                        if (username.isEmpty) {
                          return 'Please enter your username or email';
                        }

                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'hunter2',
                        labelText: 'Password',
                      ),
                      initialValue: password,
                      obscureText: true,
                      onSaved: (value) => password = value,
                      style: textStyle,
                      validator: (password) {
                        if (password.isEmpty) {
                          return 'Please enter your password to login';
                        }

                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: MaterialButton(
                      child: Text(
                        'Submit',
                        style: textStyle.copyWith(
                          color: isLoggingIn
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).accentColor,
                        ),
                      ),
                      onPressed: _login,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() {
    if (isLoggingIn) return;

    final form = _formKey.currentState;
    if (!form.validate()) return;
    form.save();

    setState(() => isLoggingIn = true);
    ApiInheritedWidget.of(context).api
        .login(username, password)
        .then((token) => Navigator.pop(context, true))
        .catchError((e) => showApiErrorDialog(context, 'Login error', e))
        .whenComplete(() => setState(() => isLoggingIn = false));
  }
}
