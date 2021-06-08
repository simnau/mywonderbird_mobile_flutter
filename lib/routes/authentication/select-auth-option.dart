import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mywonderbird/components/link-account-dialog.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/routes/authentication/sign-in.dart';
import 'package:mywonderbird/routes/authentication/sign-up.dart';
import 'package:mywonderbird/util/apple.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
          image: AssetImage('images/mywonderbird-travel.png'),
          fit: BoxFit.cover,
        )),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 64, 32, 96),
          child: Column(
            children: <Widget>[
              _logo(),
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
    return SizedBox(
      width: 120,
      height: 120,
      child: Image(
        image: AssetImage('images/logo.png'),
      ),
    );
  }

  Widget _authOptions() {
    final theme = Theme.of(context);

    return Builder(builder: (context) {
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
              onPressed: () => _onFacebookFlow(context),
              child: BodyText1.light('CONTINUE WITH FACEBOOK'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF3B5798),
              ),
            ),
            ElevatedButton(
              onPressed: () => _onGoogleFlow(context),
              child: BodyText1.light('CONTINUE WITH GOOGLE'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFDB4437),
              ),
            ),
            if (Platform.isIOS)
              ElevatedButton(
                onPressed: () => _onAppleFlow(context),
                child: BodyText1.light('CONTINUE WITH APPLE'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                ),
              ),
          ],
        ),
      );
    });
  }

  _signIn() {
    Navigator.of(context).pushNamed(SignIn.RELATIVE_PATH);
  }

  _signUp() {
    Navigator.of(context).pushNamed(SignUp.RELATIVE_PATH);
  }

  _onFacebookFlow(BuildContext context) async {
    final result = await FacebookAuth.instance.login();

    var error;

    switch (result.status) {
      case LoginStatus.cancelled:
        error = 'Operation cancelled';
        break;
      case LoginStatus.failed:
        error = 'There was an error signing in';
        break;
      case LoginStatus.operationInProgress:
        error = 'The operation is still in progress';
        break;
      default:
        final credential =
            FacebookAuthProvider.credential(result.accessToken.token);

        try {
          return await FirebaseAuth.instance.signInWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          switch (e.code) {
            case 'account-exists-with-different-credential':
              error = await _handleExistingAccount(
                email: e.email,
                credential: credential,
              );
              break;
            default:
              error = 'There was an error signing you in';
              break;
          }
        } catch (e) {
          error = 'There was an error signing you in';
        }
    }

    if (error != null) {
      final snackBar = createErrorSnackbar(text: error);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _onGoogleFlow(BuildContext context) async {
    var error;

    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        final snackBar = createErrorSnackbar(text: 'Operation cancelled');
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          error = 'Invalid password / email combination';
          break;
        case 'too-many-requests':
          error = 'You made too many attempts to sign in. Try again later';
          break;
        default:
          error = 'There was an error signing you in';
          break;
      }
    } catch (e) {
      error = 'There was an error signing you in';
    }

    if (error != null) {
      final snackBar = createErrorSnackbar(
        text: error,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _onAppleFlow(BuildContext context) async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    var error;

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    if (appleCredential == null) {
      final snackBar = createErrorSnackbar(text: 'Operation cancelled');
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    try {
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          error = _handleExistingAccount(
            email: e.email,
            credential: credential,
          );
          break;
        default:
          error = 'There was an error signing you in';
          break;
      }
    } catch (e) {
      error = 'There was an error signing you in';
    }

    if (error != null) {
      final snackBar = createErrorSnackbar(text: error);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  _handleExistingAccount({
    String email,
    AuthCredential credential,
  }) async {
    final providers =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

    final oldCredential = await showDialog(
      context: context,
      builder: (context) => LinkAccountDialog(
        providers: providers,
        email: email,
      ),
    );

    if (oldCredential == null) {
      return 'Unable to retrieve account credentials';
    }

    if (credential != null) {
      try {
        await FirebaseAuth.instance.signInWithCredential(oldCredential);
        await FirebaseAuth.instance.currentUser.linkWithCredential(credential);
        return null;
      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'wrong-password':
            return 'Invalid password / email combination';
          case 'too-many-requests':
            return 'You made too many attempts to sign in. Try again later';
          default:
            return 'There was an error signing you in';
        }
      } catch (e) {
        return 'There was an error signing you in';
      }
    }
  }
}
