import 'package:flutter/material.dart';
import 'package:layout/constants/oauth.dart';
import 'package:layout/locator.dart';
import 'package:layout/providers/oauth.dart';
import 'package:layout/routes/authentication/sign-in.dart';
import 'package:layout/routes/authentication/sign-up.dart';
import 'package:url_launcher/url_launcher.dart';

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
          RaisedButton(
            onPressed: _onFacebookFlow,
            child: Text('CONTINUE WITH FACEBOOK'),
            color: Color(0xFF3B5798),
            textColor: Colors.white,
          ),
          RaisedButton(
            onPressed: _onGoogleFlow,
            child: Text('CONTINUE WITH GOOGLE'),
            color: Colors.white,
            textColor: Color(0xFF757575),
          ),
        ],
      ),
    );
  }

  _signIn() {
    Navigator.of(context).pushNamed(SignIn.RELATIVE_PATH);
  }

  _signUp() {
    Navigator.of(context).pushNamed(SignUp.RELATIVE_PATH);
  }

  _onFacebookFlow() async {
    final authorizeUrl = locator<OAuthProvider>().authorizeUrl;
    final redirectUrl =
        "$authorizeUrl&redirect_uri=$FB_SIGN_IN_REDIRECT_URL&identity_provider=Facebook";

    if (await canLaunch(redirectUrl)) {
      await launch(redirectUrl);
    } else {
      throw 'Could not launch $redirectUrl';
    }
  }

  _onGoogleFlow() async {
    final authorizeUrl = locator<OAuthProvider>().authorizeUrl;
    final redirectUrl =
        "$authorizeUrl&redirect_uri=$GOOGLE_SIGN_IN_REDIRECT_URL&identity_provider=Google";

    if (await canLaunch(redirectUrl)) {
      await launch(redirectUrl);
    } else {
      throw 'Could not launch $redirectUrl';
    }
  }
}
