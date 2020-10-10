import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/constants/oauth.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/providers/oauth.dart';
import 'package:mywonderbird/routes/authentication/sign-in.dart';
import 'package:mywonderbird/routes/authentication/sign-up.dart';
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
            child: BodyText1('SIGN IN'),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(color: theme.accentColor),
            ),
          ),
          RaisedButton(
            onPressed: _signUp,
            child: BodyText1.light('SIGN UP'),
            color: theme.accentColor,
          ),
          RaisedButton(
            onPressed: _onFacebookFlow,
            child: BodyText1.light('CONTINUE WITH FACEBOOK'),
            color: Color(0xFF3B5798),
          ),
          RaisedButton(
            onPressed: _onGoogleFlow,
            child: BodyText1(
              'CONTINUE WITH GOOGLE',
              color: Color(0xFF757575),
            ),
            color: Colors.white,
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
