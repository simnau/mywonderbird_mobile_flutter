import 'package:flutter/material.dart';
import 'package:layout/routes/authentication/sign-in.dart';
import 'package:layout/routes/authentication/sign-up.dart';

class SelectAuthOption extends StatefulWidget {
  static const RELATIVE_PATH = 'select-auth-option';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SelectAuthOptionState createState() => _SelectAuthOptionState();
}

class _SelectAuthOptionState extends State<SelectAuthOption> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/mywonderbird-travel.jpg'),
          fit: BoxFit.cover,
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 32.0,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _logo(),
              ),
              Expanded(
                flex: 2,
                child: _authOptions(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Image(
        image: AssetImage('images/logo.png'),
      ),
    );
  }

  Widget _authOptions() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RaisedButton(
            onPressed: _signIn,
            child: Text('SIGN IN'),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: theme.accentColor),
            ),
          ),
          RaisedButton(
            onPressed: _signUp,
            child: Text(
              'SIGN UP',
              style: TextStyle(color: Colors.white),
            ),
            color: theme.accentColor,
          ),
        ],
      ),
    );
  }

  void _signIn() {
    Navigator.of(context).pushNamed(SignIn.RELATIVE_PATH);
  }

  void _signUp() {
    Navigator.of(context).pushNamed(SignUp.RELATIVE_PATH);
  }
}
