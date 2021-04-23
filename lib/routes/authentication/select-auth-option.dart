import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mywonderbird/components/link-account-dialog.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/routes/authentication/sign-in.dart';
import 'package:mywonderbird/routes/authentication/sign-up.dart';

class SelectAuthOption extends StatefulWidget {
  static const RELATIVE_PATH = 'select-auth-option';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _SelectAuthOptionState createState() => _SelectAuthOptionState();
}

class _SelectAuthOptionState extends State<SelectAuthOption> {
  String _error;

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
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: BodyText1.light(_error),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(top: 8),
                  child: BodyText1.light(''),
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
          ElevatedButton(
            onPressed: _signIn,
            child: BodyText1('SIGN IN'),
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: theme.accentColor),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _signUp,
            child: BodyText1.light('SIGN UP'),
            style: ElevatedButton.styleFrom(
              primary: theme.accentColor,
            ),
          ),
          ElevatedButton(
            onPressed: _onFacebookFlow,
            child: BodyText1.light('CONTINUE WITH FACEBOOK'),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF3B5798),
            ),
          ),
          ElevatedButton(
            onPressed: _onGoogleFlow,
            child: BodyText1.light('CONTINUE WITH GOOGLE'),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFDB4437),
            ),
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
    final result = await FacebookAuth.instance.login();

    switch (result.status) {
      case LoginStatus.cancelled:
        Fluttertoast.showToast(
          msg: 'The user has cancelled the operation',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      case LoginStatus.failed:
        Fluttertoast.showToast(
          msg: 'There was an error signing in',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      case LoginStatus.operationInProgress:
        Fluttertoast.showToast(
          msg: 'The operation is still in progress',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      default:
        final credential =
            FacebookAuthProvider.credential(result.accessToken.token);

        try {
          return await FirebaseAuth.instance.signInWithCredential(credential);
        } catch (e) {
          Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          final providers =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(e.email);

          final oldCredential = await showDialog(
            context: context,
            builder: (context) => LinkAccountDialog(
              providers: providers,
              email: e.email,
            ),
          );

          if (credential != null) {
            await FirebaseAuth.instance.signInWithCredential(oldCredential);
            await FirebaseAuth.instance.currentUser
                .linkWithCredential(credential);
            return;
          }
        }
    }
  }

  _onGoogleFlow() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Fluttertoast.showToast(
          msg: 'The user has cancelled the operation',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final providers = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(googleUser.email);

      if (providers.isNotEmpty && !providers.contains(GOOGLE_PROVIDER)) {
        final oldCredential = await showDialog(
          context: context,
          builder: (context) => LinkAccountDialog(
            providers: providers,
            email: googleUser.email,
          ),
        );

        if (credential != null) {
          await FirebaseAuth.instance.signInWithCredential(oldCredential);
          await FirebaseAuth.instance.currentUser
              .linkWithCredential(credential);
          return;
        }
      } else {
        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred. Please try again",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
